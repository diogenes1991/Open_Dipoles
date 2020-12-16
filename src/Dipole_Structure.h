#ifndef __DIPOLE_STRUCTURE_H__
#define __DIPOLE_STRUCTURE_H__

#include "nlox_process.h"
#include "Dipole_Definitions.h"
#include <string>
#include <unordered_map>
#include <iostream>

#define DEBUG 0

class DipoleStructure {

    public:

        Process * Proc;
        std::unordered_map<std::string,int> BornMap;

        FourVector* Momenta;
        double* Masses;
        int* PID;

        int nBorn,nPar;
        FourVector* BornMomenta;
        double** BornMasses;
        int** BornPID;
        
        virtual ~DipoleStructure(){
            for (int i=0; i<nBorn; i++){
                delete BornMasses[i];
                delete BornPID[i];
            }
            delete [] BornMasses;
            delete [] BornPID;

            delete BornMomenta;
            delete PID;
            delete Masses;
            delete Momenta;
        }

        void BGenerate(std::string Born, double sqrts, double* rand, double* Jac){
            
            int BornNum = BornMap.at(Born);
            double dummy;
            FourVector P(sqrts,0,0,0);

            FourVector PIn[2];
            double mIn[2]={BornMasses[BornNum][0],BornMasses[BornNum][1]};
            double rIn[2]={0.0,0.0};
            Recursive_PSP(P,2,PIn,mIn,rIn,dummy);
            BornMomenta[0] = PIn[0];
            BornMomenta[1] = PIn[1];
            
            FourVector PFi[nPar-3];
            double mFi[nPar-3];
            for (int i=0;i<nPar-3;i++) mFi[i] = BornMasses[BornNum][i+2];
            dummy = 1.0;
            Recursive_PSP(P,nPar-3,PFi,mFi,rand,dummy);
            for (int i=0;i<nPar-3;i++) BornMomenta[i+2] = PFi[i];
            *Jac = dummy;    

        }

        void SGenerate(double sqrts, double* rand, double* Jac){

            double dummy;
            FourVector P(sqrts,0,0,0);

            FourVector PIn[2];
            double mIn[2]={Masses[0],Masses[1]};
            double rIn[2]={0.0,0.0};
            Recursive_PSP(P,2,PIn,mIn,rIn,dummy);
            Momenta[0] = PIn[0];
            Momenta[1] = PIn[1];
            
            FourVector PFi[nPar-2];
            double mFi[nPar-2];
            for (int i=0;i<nPar-2;i++) mFi[i] = Masses[i+2];
            dummy = 1.0;
            Recursive_PSP(P,nPar-2,PFi,mFi,rand,dummy);
            for (int i=0;i<nPar-2;i++) Momenta[i+2] = PFi[i];
            *Jac = dummy;    

        }

        void PGenerate(std::string Born, double sqrts, double* rand, double* Jac){
            // This generates a dedicated PSP_Generator for 
            // Plus Distributions

            // Fork on TYP = {II,IF,FI} -> FF does not have P Integrands

            int BornNum = BornMap.at(Born);

            if(TYP=="II"){
                sqrtshat = BornMasses[BornNum][0]*BornMasses[BornNum][0]+BornMasses[BornNum][1]*BornMasses[BornNum][1]+sqrts*rand[3*nPar-4];
                BGenerate(sqrtshat,rand,Jac);
            }

            else if (TYP=="IF" or TYP=="FI"){

                // For these configurations the issue is a bit more complex, the 
                // reason is that we split the integration variables into dPhi(F)xdPhi(All other finals)
                // the first piece contains 2 variables the square of all others and the polar angle of
                // pF (the azimuth is redundant and we integrate over it). The issue is that the Square 
                // of all others is fixed if the set of all others contains only one particle, this means 
                // that the second term has -1 degress of freedom -> there is a leftover delta function 
                // if we insist in doing this we generate a very unstable integrand since it is only 
                // supported on a zero measure set... 
                // To avoid this problem we simply have to define two generators, one when the set of all others
                // has only one particle (a.k.a. nPar=4) and one when it doesn't.

                // (3nf-4) -> 2(+1) + (3nf-7)

                if(nPar==4){
                    double KiaSq = BornMasses[BornNum][]*BornMasses[BornNum][];
                }
                else{
                    double KiaSq_min = 
                    double KiaSq = KiaSq_min + rand[]*(KiaSq_max-KiaSq_min);

                }

            }


        }

        void GetMomenta(FourVector* p){

            for(int i=0;i<nPar;i++)p[i]=Momenta[i];
        }

        void GetMasses(double* m){

            for(int i=0;i<nPar;i++)m[i]=Masses[i];
        }

        void GetPID(int* pid){

            for(int i=0;i<nPar;i++)pid[i]=PID[i];
        }

        virtual void Subtracted(std::string cp, double sqrts, double* rand, double mu, double* rval) = 0;
        virtual void PlusDistribution(std::string cp, double sqrts, double* rand, double mu, double* rval) = 0;
        virtual void Endpoint(std::string cp, double sqrts, double* rand, double mu, double* rval) = 0;

};

#endif


