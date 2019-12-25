/*
 ============================================================================
 
 Author      : Ztiany
 Description : run-time type indentification, 运行时类型识别

 ============================================================================
 */

#include "rtti.h"
#include <string>
#include <cstdlib>

using namespace std;

int main() {

    string name1("BaseWithVirtual");
    string name2("DeriveWithVirtual");
    string name3("name1");
    string name4("name1");

    string address1("a1");
    string address2("a2");

    BaseWithVirtual baseWithVirtual(name1, 90);
    DeriveWithVirtual deriveWithVirtual(name2, 89, address1);

    BaseWithoutVirtual baseWithoutVirtual(name3, 88);
    DeriveWithoutVirtual deriveWithoutVirtual(name4, 87, address2);

    baseWithVirtual.printInfo();
    deriveWithVirtual.printInfo();
    baseWithoutVirtual.printInfo();
    deriveWithoutVirtual.printInfo();

    BaseWithVirtual *baseWithVirtualTempP = &deriveWithVirtual;
    if (auto *tempP = dynamic_cast<DeriveWithVirtual *>(baseWithVirtualTempP)) {
        cout << "dynamic_cast<DeriveWithVirtual *>(&baseWithVirtual) success" << endl;
        tempP->printInfo();
    } else {
        cout << "dynamic_cast<DeriveWithVirtual *>(&baseWithVirtual) failed" << endl;
    }

    BaseWithVirtual &baseWithVirtualTempR = deriveWithVirtual;
    try {
        auto &tempR = dynamic_cast<DeriveWithVirtual &>(baseWithVirtualTempR);
        cout << "dynamic_cast<DeriveWithVirtual &>(baseWithVirtualTempR) success" << endl;
        tempR.printInfo();
    } catch (bad_cast) {
        cout << "dynamic_cast<DeriveWithVirtual &>(baseWithVirtualTempR) failed" << endl;
    }

    //BaseWithoutVirtual' is not polymorphic，必须有虚函数才能使用 dynamic_cast
    /*BaseWithoutVirtual *baseWithoutVirtualTemp = &deriveWithoutVirtual;
    if (auto *tempV = dynamic_cast<DeriveWithoutVirtual *>(baseWithoutVirtualTemp)) {
        cout << " dynamic_cast<DeriveWithoutVirtual *>(baseWithoutVirtualTemp) success" << endl;
    } else {
        cout << " dynamic_cast<DeriveWithoutVirtual *>(baseWithoutVirtualTemp) failed" << endl;
    }*/

    return EXIT_SUCCESS;
}