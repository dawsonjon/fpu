#include <iostream>
#include <iomanip>
#include <stdint.h>
using namespace std;

int main()
{
	float f = 1.0;
	unsigned int i;
	uint32_t a;

	while(1){
		cin >> a;
		f = *(float*)&a;
		i = (int)f;
		cout << i << endl;
	}

	return 0;
}
