#include <iostream>
#include <iomanip>
using namespace std;

int main()
{
	float f = 1.0;
	unsigned int a, b, i;

	cin >> a;
	cin >> b;
	f = *(float*)&a + *(float*)&b;
	i = *(int*)&f;

	cout << hex << i << endl;

	return 0;
}
