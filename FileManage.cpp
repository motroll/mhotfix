
#include "FileManage.h"
#include <sys/stat.h>
#include <io.h>
#include <iostream>

using namespace std;

FileManage::FileManage(string filePath)
{
    luaFilePath.push_back(filePath);
}
FileManage::~FileManage()
{
	luaFilePath.clear();
	fileInfoMap.clear();
	modifyFileMap.clear();
}

void  FileManage::addFilePath(string filePath)
{
    luaFilePath.push_back(filePath);
}

void FileManage::checkOneFileUpdate(string moduleFile,string filePath, long modifyTime)
{
     _FileData f; 
    map<string,_FileData>::iterator iterFile = this->fileInfoMap.find(moduleFile);
    if (iterFile == this->fileInfoMap.end())
    {
        
        f.filePathName = filePath;
        f.modifyTime = modifyTime; 
        this->fileInfoMap.insert(pair<string,_FileData>(moduleFile, f));
        this->modifyFileMap.insert(pair<string,_FileData>(moduleFile, f));
    }
    else
    {
        f = iterFile->second; 
        if(f.modifyTime !=modifyTime)
        {
            iterFile->second.modifyTime = modifyTime;
            this->modifyFileMap.insert(pair<string,_FileData>(moduleFile, f));
        }
    }
   
}

//获取目录下的所有lua文件 
void FileManage::getPathAllFiles(string dirPath) 
{
    intptr_t  hFile = 0; 
    struct _finddata_t fileInfo; 
    struct _stat tmpInfo;
    string p; 

    if((hFile = _findfirst(p.assign(dirPath).append("\\*").c_str(), &fileInfo))==-1)
    {
        return;
    }    
    do
    {
        if(fileInfo.attrib &_A_SUBDIR)
        {
            if(strcmp(fileInfo.name, ".") !=0 && strcmp(fileInfo.name, "..")!=0)
            {
        
                string file  = p.assign(dirPath).append("\\").append(fileInfo.name);
                this->getPathAllFiles(file );
            }
        }
        else{
        
            string fileName = fileInfo.name;  
            char * backName = strchr(fileName.c_str(), '.');
            if (strcmp(backName, ".lua") == 0)  //帅选lua文件
            {
                string filePre = fileName.substr(0,fileName.length() - strlen(backName));
                string moduleFile  = p.assign(dirPath).append("\\").append(filePre);
                string filePath = p.assign(dirPath).append("\\").append(fileName);
                if(_stat(filePath.c_str(), &tmpInfo) !=0)
                {
                    return ;
                }
                this->checkOneFileUpdate(filePre,moduleFile, tmpInfo.st_mtime);
            }
        }
    }while(_findnext(hFile, &fileInfo) == 0);
}

void FileManage::getAllFile()
{
    this->modifyFileMap.clear();
    vector<string>::iterator iter = luaFilePath.begin();
    for(; iter !=luaFilePath.end(); iter++)
    {
        this->getPathAllFiles(*iter); 
    } 
}
