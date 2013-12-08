#include <iostream>
#include <iomanip>
using namespace std;

int main()
{
	float f = 1.0;
	unsigned int a, b, i;

	while(1){
		cin >> a;
		cin >> b;
		f = *(float*)&a * *(float*)&b;
		i = *(int*)&f;
		cout << i << endl;
	}

	return 0;
}
