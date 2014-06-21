#include <iostream>
#include <iomanip>
#include <stdint.h>
using namespace std;

int main()
{
	double f = 1.0;
	uint64_t i;
	uint64_t a;

	while(1){
		cin >> a;
		f = *(double*)&a;
		i = (uint64_t)f;
		cout << i << endl;
	}

	return 0;
}
