#include <iostream>
#include <iomanip>
using namespace std;

int main()
{
	double f = 1.0;
	long unsigned int a, b, i;

	while(1){
		cin >> a;
		cin >> b;
		f = *(double*)&a * *(double*)&b;
		i = *(long unsigned int*)&f;
		cout << i << endl;
	}

	return 0;
}
