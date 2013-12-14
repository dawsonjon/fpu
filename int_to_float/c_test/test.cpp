#include <iostream>
#include <iomanip>
using namespace std;

int main()
{
	float f = 1.0;
	unsigned int a, i;

	while(1){
		cin >> a;
		f = float(a);
		i = *(int*)&f;
		cout << i << endl;
	}

	return 0;
}
