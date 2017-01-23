/*
 Executable file location: /usr/local/bin
*/

#include <iostream>
#include <string>
#include <stdio.h>
#include <fstream>
#include <vector>
using namespace std;

bool file_exists(string filename) {
    
    ifstream file(filename);
    
    return file.good();
    
}

string get_cwd() {
    
    string data;
    FILE * stream;
    int buffer_size = 100;
    char buffer[buffer_size];
    
    stream = popen("pwd", "r");
    if (stream) {
        
        while (!feof(stream)) {
            
            if (fgets(buffer, buffer_size, stream) != NULL) data.append(buffer);
            
        }
        
    }
    
    return data;
    
}

int main(int argc, char* argv[]) {
    
    if (argc == 2) {
        
        string command = "g++ ";
        command += argv[1];
        
        system(command.c_str());
        system("./a.out");
        system("rm ./a.out");
        
    } else {
        
        cout << "Usage: bar [file]" << endl;
        cout << "NOTE: Call in directory of file" << endl;
        
    }
    
    return 0;
}