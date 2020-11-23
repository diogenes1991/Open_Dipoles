#ifndef _UTILITIES_H
#define _UTILITIES_H

template <class T>
class ColorAndSpinMatrixT{

    public:
        T*** ccsc;
        int n;
        ColorAndSpinMatrixT(int NCC){
            n = NCC;
            ccsc = new T**[n];
            for(int cc=0;cc<n;cc++){
                ccsc[cc] = new T*[4];
                for(int mu=0;mu<4;mu++){
                    ccsc[cc][mu] = new T[4];
                }
            }
        }
        ~ColorAndSpinMatrixT(){
            for(int cc=0;cc<n;cc++){
                for(int mu=0;mu<4;mu++){
                    delete [] ccsc[cc][mu];
                }
                delete [] ccsc[cc];
            }
            delete [] ccsc;
        }
        void Show(){
            for(int cc=0;cc<n;cc++){
                FourMatrixT<T> Bmunu(ccsc[cc]);
                std::cout<<"B("<<cc<<")= \n";
                std::cout<<Bmunu<<std::endl;
            }
        }
};

typedef ColorAndSpinMatrixT<double> ColorAndSpinMatrix;

#endif
