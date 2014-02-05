#include <cmath>

#define ZERO_F (0.0f)

int main(void) {
	float fzero, x;
	fzero = ZERO_F;
	x = ZERO_F / fzero;
	return isnan(x);
}
