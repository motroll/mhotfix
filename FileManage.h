
#ifndef  __FILEMANAGE_H 
#define  __FILEMANAGE_H 

#include <string>
#include <vector>
#include <map>

using namespace std;

typedef struct FileData
{
    string filePathName;                //文件目录
    long modifyTime;                    //修改时间 
}_FileData;

class FileManage
{

public:
    FileManage(string filePath); 
    ~FileManage();


    void addFilePath(string filePath);  //添加lua文件目录
    void getAllFile();                 //获取所有目录下文件 

    void getPathAllFiles(string filePath); //获取单个目录下文件
    void checkOneFileUpdate(string moduleFile,string filePath, long modifyTime); //检查更新文件 
private:

    vector<string>  luaFilePath; 
    map<string, _FileData>  fileInfoMap; 
public:    
    map<string, _FileData>  modifyFileMap; 

};


#endif 