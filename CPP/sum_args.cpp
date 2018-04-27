#include <iostream>
#include <vector>
#include <sstream>
using namespace std;

int main(int argc, char** argv) {
    vector<int> nums;
    int sum, tmp_int;
    for (int i=0; i<argc-1; i++) {
        stringstream(argv[i+1]) >> tmp_int;
        sum += tmp_int;
    }

    cout << sum << endl;

    return 0;
}
