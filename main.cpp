#include <io.h>
#include <iostream>
#include <map>
#include "include/lua.hpp"
#include <sys/stat.h>
#include <string>
#include <fstream>
#include <csignal>
#include "FileManage.h"

using  namespace std;


void  loadOldFile(lua_State *pState,map<string,_FileData> fileMap)
{
    map<string,_FileData> ::iterator it = fileMap.begin();
    int i = 1; 
    lua_getglobal(pState,"loadFiles"); 
    lua_newtable(pState);
    for( it; it !=fileMap.end(); it++)
    {
      lua_pushinteger(pState, i); 
      lua_pushstring(pState, it->second.filePathName.c_str());
      lua_settable(pState, -3); 
      i = i + 1;
    }

    lua_newtable(pState);
    i = 1;
    it = fileMap.begin();
    for( it; it !=fileMap.end(); it++)
    {
      lua_pushinteger(pState, i); 
      lua_pushstring(pState, it->first.c_str());
      lua_settable(pState, -3); 
      i = i + 1;
    }
    lua_pcall(pState, 2, 0,0);

    lua_getglobal(pState,"testBeforeUpdate"); 
    lua_pcall(pState, 0, 0,0);
}

void  updateNewFile(lua_State *pState,map<string,_FileData> fileMap)
{
    map<string,_FileData>::iterator it = fileMap.begin();
    int i = 1; 
    lua_getglobal(pState,"updateChunkList"); 
    lua_newtable(pState);

    cout << "更新了 "<< fileMap.size() << "个文件" <<endl; 
    for( it; it !=fileMap.end(); it++)
    {
      cout << "更新了 " << it->first << endl; 
      lua_pushinteger(pState, i); 
      lua_pushstring(pState, it->second.filePathName.c_str());
      lua_settable(pState, -3); 
      i = i + 1;
      
    }

    lua_newtable(pState);
    i = 1;
    it = fileMap.begin();
    for( it; it !=fileMap.end(); it++)
    {
      lua_pushinteger(pState, i); 
      lua_pushstring(pState, it->first.c_str());
      lua_settable(pState, -3); 
      i = i + 1;
    }
    lua_pcall(pState, 2, 0,0);
}



int main(int, char**) 
{
 
    lua_State *pState = luaL_newstate();
    if(pState == nullptr)
    {
        cout << "初始化失败" << endl; 
    }
    // 加载相关库文件 
    luaL_openlibs(pState); 

    if(luaL_dofile(pState,"main.lua"))
    {
        cout << "Lua 文件加载失败" << endl; 
    }

    
    FileManage *fileM = new FileManage("./test");
    fileM->getAllFile();
    loadOldFile(pState,fileM->modifyFileMap);
  
     while(true)
    {

       string c ;  
       cin >> c ; 
       if(c == "e")
       {
          cout << "检查文件更新开始" << endl;
          fileM->getAllFile();
           cout << "获取更新文件列表" << endl;
          updateNewFile(pState,fileM->modifyFileMap);
          cout << "检查文件更新完成" << endl;
          lua_getglobal(pState,"testAfterUpdate"); 
          lua_pcall(pState, 0, 0,0);
          cout << "测试更新文件完成" << endl;
       }
    }
    delete fileM;
    return  1; 

}
