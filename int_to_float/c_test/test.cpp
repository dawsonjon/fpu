#include <iostream>
#include <iomanip>
#include <stdint.h>
using namespace std;

int main()
{
	float f = 1.0;
	unsigned int i;
	int32_t b;
	uint32_t a;

	while(1){
		cin >> a;
		b = a;
		f = float(b);
		i = *(int*)&f;
		cout << i << endl;
	}

	return 0;
}
