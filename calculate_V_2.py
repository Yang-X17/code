import sys


import os
import arcpy
from arcpy import env
from arcpy.sa import *


def shpInPath(path):
  
    shp = None
    for dirPath,dirName,fileNames in os.walk(path):
        for fileName in fileNames:
            if os.path.splitext(fileName)[-1]==".shp":
                shp =os.path.join(dirPath,fileName)
                return shp

    if shp :raise ValueError(path +"\t未找到shp文件") #(path +"\t shp file not found")


def rastersInPath(path):
  
    rasters = None
    for dirPath,dirName,fileNames in os.walk(path):
        for fileName in fileNames:
            if os.path.splitext(fileName)[-1]==".tif":
                rasters=os.path.join(dirPath,fileName)
                return rasters

    if rasters :raise ValueError(path +"\t缓冲区tif文件")#(path +"\t buffer zone tif file")

    
def allRastersInPath(path):
 
    rasters = []
    for dirPath,dirName,fileNames in os.walk(path):
        for fileName in fileNames:
            if os.path.splitext(fileName)[-1]==".tif":
                rasters.append(os.path.join(dirPath,fileName))

    if len(rasters)== 0:raise ValueError(path +"\t未找到tif") #(path +"\t tif file not found")
    return rasters

def calculate(region,field,flood,floodClass,nightLights):

    def rastersInPath(path):
      
        rasters = []
        for dirPath,dirName,fileNames in os.walk(path):
            for fileName in fileNames:
                if os.path.splitext(fileName)[-1]==".tif":
                    rasters.append(os.path.join(dirPath,fileName))

        if len(rasters)== 0:raise ValueError(path +"\t未找到tif") #(path +"\t tif file not found")
        return rasters


    def calculateYear(year,region,field,flood,floodClass,nightLights):
        def nightLightInRasters(year,rasters):
            nightLight = None
            for raster in rasters:
                if year in raster.split("_")[-2]:
                    nightLight = raster
                    return nightLight
            
            if nightLight is None:
                raise ValueError("failed get raster in path")

        year = str(year)

        nightLight = nightLightInRasters(year,nightLights)
        print(nightLight)
        nightLight = Int(nightLight)
        nightLight = ExtractByMask(nightLight, flood)

        # calculate weight
        outTable1 = ZonalStatisticsAsTable(in_zone_data=region,zone_field=field,\
            in_value_raster=nightLight,out_table ="_".join([str(field),str(floodClass),str(year),"weight"])\
                + ".dbf",\
                statistics_type="SUM")

        nightLight = Times(nightLight,flood)

        # Calculate buffer zone x night light
        outTable2 = ZonalStatisticsAsTable(in_zone_data=region,zone_field=field,\
            in_value_raster=nightLight,out_table ="_".join([field,floodClass,year,"flood"])+ ".dbf",\
                statistics_type="SUM")
    
    nightLights = rastersInPath(nightLights)

    for year in range(1992,2021):
        print(year)
        calculateYear(year,region,field,flood,floodClass,nightLights)
    
    return 1


def tablesInPath(path,floodClass,extensions):
    tables = []
    for dirPath,dirName,fileNames in os.walk(path):
        for fileName in fileNames:
            if (extensions in fileName) and (floodClass in fileName):
                tables.append(os.path.join(dirPath,fileName))
    return tables

def addFieldValue(year,inFeatures,field,floodTables,weightTables):
    def yearTables(year,tables):
        yearDbf = None
        for table in tables:
            if year in table:
                yearDbf = table
                return yearDbf
        
        if yearDbf is None:
            raise ValueError("failed get raster in path")

    year = str(year)
    arcpy.AddField_management(inFeatures,"Y"+year,"DOUBLE")
    floodTable = yearTables(year,floodTables)
    weightTable = yearTables(year,weightTables)
    tableFields = [field,'SUM']
    shpFields = [field,"Y"+year]#



    with arcpy.da.SearchCursor(floodTable, tableFields) as floodCurosr:
        for flood in floodCurosr:
            with arcpy.da.SearchCursor(weightTable, tableFields) as weightCurosr:
                for weight in weightCurosr:
                    if flood[0] == weight[0]:
                        with arcpy.da.UpdateCursor(inFeatures, shpFields) as cursor:
                            for row in cursor:
                                if flood[0] == row[0] and flood[1]!=0 and weight[1]!=0:
                                    row[1] = flood[1]/weight[1]
                                    cursor.updateRow(row)
                                    print(flood,weight,row,row[1])
                                    






# Folder containing nighttime light
nightLights = r"..\static\nightlight"

# Buffer tif file path
flood = rastersInPath(r".\flood")

# Vector file path 
region = shpInPath(r".\shp")

# output location 
workspace = ".\workspace"
arcpy.env.workspace = workspace


# buffer zone
floodClass = "use_flood"


# Retrieve statistical fields from the command line
field = sys.argv[1]

print("夜间灯光文件夹\t" + nightLights) # print("Nighttime Light Folder\t" + nightLights)
print("夜间灯光栅格\t") # print("Nighttime Light grid\t" + nightLights)
print(allRastersInPath(nightLights))
print("缓冲区栅格\t" + flood) # print("Buffer Grid\t" + flood) 
print("统计shp\t" + region) #print("Statistical shp\t" + region)
print("工作空间\t" + workspace) #print("workspace\t" + workspace)
print("缓冲区类型（可选）\t" + floodClass) #print("Buffer type (optional)\t" + floodClass)
print("统计字段\t" +field) #print("Statistics Field\t" +field)

if __name__=="__main__":
    # Calculate dbf
    calculate(region,field,flood,floodClass,nightLights)


    # Calculate field values
    
    floodTables = tablesInPath(workspace,floodClass,"flood.dbf")

    weightTables = tablesInPath(workspace,floodClass,"weight.dbf")


    for year in range(1992,2021):
        print(year)
        addFieldValue(year,region,field,floodTables,weightTables)
