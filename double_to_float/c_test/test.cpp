#include <iostream>
#include <iomanip>
#include <stdint.h>
using namespace std;

int main()
{
	double f = 1.0;
	float i;
	uint64_t a;
	uint32_t z;

	while(1){
		cin >> a;
		f = *(double*)&a;
		i = (float)f;
        z = *(uint32_t*)&i;
		cout << z << endl;
	}

	return 0;
}
