#include <iostream>
#include <string>
using namespace std;

#if defined(_WIN32) || defined(_WIN64)
#define win
#elif defined(__linux__) || defined(__unix__)
#define linux
#elif defined(__APPLE__)
#define mac
#else
#define none
#endif

int main(int argc, char* argv[]) {
	if (argc == 2) {
		string filename = argv[1];

		#if defined(win)
		string outfile = filename.substr(0, filename.size()-4) + ".exe";
		string cmd_gcc = "g++ " + filename + " -o " + outfile;
		string cmd_run = outfile;
		string cmd_rm = "del " + outfile;
		#elif defined(linux) || defined(mac)
		string outfile = filename.substr(0, filename.size()-4);
		string cmd_gcc = "g++ " + filename + " -o " + outfile;
		string cmd_run = "./ " + filename;
		string cmd_rm = "rm " + outfile;
		#endif

		system(cmd_gcc.c_str());
		system(cmd_run.c_str());
		system(cmd_rm.c_str());

		return 0;
	} else {
		cout << "Usage: bar [file]" << endl;
		cout << "NOTE: Run in directory of c++ file" << endl;

		return 1;
	}
}
