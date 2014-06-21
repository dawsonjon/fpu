#include <iostream>
#include <iomanip>
#include <stdint.h>
using namespace std;

int main()
{
    uint32_t a;
    float b;
	double f = 1.0;
	uint64_t i;

	while(1){
		cin >> a;
        b = *(float*)&a;
		f = (double)b;
		i = *(uint64_t*)&f;
		cout << i << endl;
	}

	return 0;
}
