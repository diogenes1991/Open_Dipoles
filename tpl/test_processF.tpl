program ftest_process
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                                                    !
!         T E S T   P R O G R A M                                    !
!                                                                    !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! For Fortran programs, the following needs to be included in order to use.
! NLOX - it is the only include needed to use the generated NLOX processes.
include 'nlox_fortran_interface.f90'

! Dummy variables
character(len=99) :: fname,cp
integer :: ierr
integer :: argc
! NLOX PSP input
! Declares the double precision arrays pp and rvalcc
////pp_dimension
integer :: next
! Test program / NLOX input
character(len=99) :: isubarg
integer :: isub
integer :: i,j,k,cccounter
character(len=9) :: typ
integer :: ltyp, lcp
character(len=99) :: muarg
double precision :: mu
character(len=99) :: ccyesnoarg
integer :: ccyesno
! NLOX output
double precision, dimension(3) :: rval2
double precision, dimension(4) :: rval
double precision :: acc2, acc, acccc

argc = command_argument_count()
if (argc > 5) then
  write(*,*) "Too many input arguments!"
  write(*,*) "Only four input arguments allowed, i.e."
  write(*,*) "  1) the integer that specifies the subprocess: see SUBPROCESSES file,"
  write(*,*) "  2) the string that specifies the interference type: tree_tree or tree_loop,"
  write(*,*) "  3) the string that specifies the coupling-power combination: asXaeY or gI'eJ'_gIeJ,"
  write(*,*) "  4) a fixed scale mu in GeV,"
  write(*,*) "  5) an optional 5th argument may be given: an integer 0 or 1 to"
  write(*,*) "  specify whether color-correlated Born MEs should be evaluated"
  write(*,*) "  and printed in addition (1) or not (0; default). Note that for" 
  write(*,*) "  tree_loop there are no color-correlated Born MEs generated."
  write(*,*) "Abort now."
  call abort()
else if (argc < 4) then
  write(*,*) "Not enough input arguments!"
  write(*,*) "Four input arguments needed, i.e."
  write(*,*) "  1) the integer that specifies the subprocess: see SUBPROCESSES file,"
  write(*,*) "  2) the string that specifies the interference type: tree_tree or tree_loop,"
  write(*,*) "  3) the string that specifies the coupling-power combination: asXaeY or gI'eJ'_gIeJ,"
  write(*,*) "  4) a fixed scale mu in GeV."
  write(*,*) "  An optional 5th argument may be given: an integer 0 or 1 to"
  write(*,*) "  specify whether color-correlated Born MEs should be evaluated"
  write(*,*) "  and printed in addition (1) or not (0; default). Note that for" 
  write(*,*) "  tree_loop there are no color-correlated Born MEs generated."
  write(*,*) "Abort now."
  call abort()
end if

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! PHASE SPACE POINT
! (this is absolutely user/MC dependent, and only the form of the PSP
! pp is relevant)

! pp stores the phase-space point. It is an array of double precision
! numbers of length 5 * (number of external particles).
!
! The elements of pp are
!
!    pp = [p1t, p1x, p1y, p1z, m1, p2t, p2x, ...]
!
! This is the format used by the BLHA2 standard. 
!
! NOTE: NLOX does currently not use the mass components, nor the last
! five entries of pp.
!
! There may be several phase-space points listed. Comment out all but
! the one you want to use.

////phase_space_point

! Convert PSP to BLHA format.
////setPCM

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! NLOX

! OLP_Start initializes the C++ code generated by NLOX. It should only
! be called once. Neither argument is used.
call NLOX_OLP_Start(fname, ierr)

! The NLOX_OLP_EvalSubProcess* functions return the pole coefficients on
! the level of the squared amplitude. We have:
!
!   NLOX_OLP_EvalSubProcess_All(&isub, pp, &next, &mu, rval, &acc);
!   NLOX_OLP_EvalSubProcess(&isub, typ, ltyp, cp, lcp, pp, &next, &mu, rval2, &acc);
!   NLOX_OLP_EvalSubProcess_CC(&isub, typ, ltyp, cp, lcp, pp, &next, &mu, rvalcc, &acc);
!
! The argument isub should be set to the ID of the subprocess in question. It
! can be determined from code/nlox_process.h or the SUBPROCESSES file, in the 
! process folder of the process archive in question.
! 
! The argument typ should be set to either tree_tree or tree_loop.
!
! The argument ltyp is the dimension of the argument typ.
! 
! The argument cp determines the coupling-power combination: It should be set
! to either asXaeY or gI'eJ'_gIeJ, the latter case being used if the separate
! cp contributions to a particular asXaeY are required,  where X=(I'+I)/2 and
! Y=(J'+J)/2, and where X+Y=next-2 for tree_tree an X+Y=next-1 for tree_loop.
! The SUBPROCESSES file contains the possible coupling-power combinations for
! the process at hand.
!
! The argument lcp is the dimension of the argument cp.
!
! NLOX_OLP_EvalSubProcess_All does neither take cp nor typ as input, as for a
! given subprocess, it sums up all coupling-power combinations that exist for
! each interference-type of that subprocess in the given process archive.
!
! The argument mu is a double precision number that determines the scale in 
! GeV.
!
! The return argument acc is an estimator for the numerical stability of the 
! tree_loop result for a given PSP. For NLOX_OLP_EvalSubProcess and *_All at
! the moment it returns three values: -1. if tred reports an instability, 0.
! if it does not, or - in case a non-zero single pole coefficient exists and
! tred does not report -1. - the relative difference between two single pole 
! coefficients of infrared nature, i.e. the ones of the tree_loop result and 
! of the corresponding real-emission correction (determined from a dedicated
! dipole implementation), in the form |tree_loop_pole/real_emission_pole|-1.
! The return argument acc will only return the values -1. or 0.  from tred's 
! stability check in case the requested coupling-power combination is of the
! form gI'eJ'_gIeJ. For NLOX_OLP_EvalSubProcess_CC acc simply returns 0.
! 
! The argument pp is the PSP discussed above while the argument next is the 
! number of external particles. The dimension of pp is 5*next.
! 
! For the various functions, the results are returned in double precision 
! arrays of various lenghts.
!
! * From NLOX_OLP_EvalSubProcess_All a double precision array of dimension 4
! is returned, named rval above, containing the double pole, single pole and
! finite coefficients of tree_loop, and the finite coefficient of tree_tree,
! in the form of rval(1,2,3,4)=(tree_loop double pole,tree_loop single pole, 
! tree_loop finite,tree_tree finite), summing over all coupling-power combi-
! nations.
!
! * From NLOX_OLP_EvalSubProcess a double precision array of dimension 3 is
! returned, named rval2 above,  containing the double pole, single pole and 
! finite coefficients - of either tree_loop or tree_tree - as rval2(1,2,3)=
! (double pole,single pole,finite), requested for a specific coupling-power
! combination. For tree_tree double and single pole return zero.
!
! * From NLOX_OLP_EvalSubProcess_CC a double precision array containing the
! finite coefficient of the Born ME and of all color-correlated Born MEs is
! returned, named rvalcc above. Its dimension is 1+n*(n-1)/2 for n=next ex-
! ternal particles, where rvalcc(1)=(tree_tree finite), and where the other
! (next^2-next)/2 elements contain the results of the color-correlated Born
! MEs Cjk=tree_TjTk_tree, with k<j and where the color correlators TjTk are
! inserted between the tree MEs in color space. Ti^2=C_F if i is a quark or
! antiquark; Ti^2=C_A if i is a gluon. More specifically, rvalcc will be in
! the form of  (tree_tree,tree_T1T2_tree,tree_T1T3_tree,...,tree_T1Tn_tree,
! tree_T2T3_tree,tree_T2T4_tree,...,tree_T2Tn_tree,...,tree_T(n-1)Tn_tree).  

call get_command_argument(1,isubarg)
isubarg = trim(adjustl(isubarg))
read(isubarg,*) isub

call get_command_argument(2,typ)
typ = trim(adjustl(typ))
ltyp = len(typ)

call get_command_argument(3,cp)
lcp = len(trim(adjustl(cp)))

call get_command_argument(4,muarg)
muarg = trim(adjustl(muarg))
read(muarg,*) mu

! For the subprocess with ID isub, compute the requested typ and cp
call NLOX_OLP_EvalSubProcess(isub, typ, ltyp, trim(adjustl(cp)), lcp, pp, next, mu, rval2, acc2)

write(*,*) "Sub-process ID ", isub, &
           ", interference type ", typ, &
           ", coupling-power combination ", trim(adjustl(cp)), &
           ", at a fixed scale of ", mu, " GeV:"
write(*,*) "rval2(1) (double pole) = ", rval2(1)
write(*,*) "rval2(2) (single pole) = ", rval2(2)
write(*,*) "rval2(3) (finite)      = ", rval2(3)
write(*,*) "acc = ", acc2
write(*,*) ""

! For the subprocess with ID isub, for each typ compute the sum of every cp
! that exist in the given process archive
call NLOX_OLP_EvalSubProcess_All(isub, pp, next, mu, rval, acc)

write(*,*) "Sub-process ID ", isub, &
           ", at a fixed scale of ", mu, " GeV:"
write(*,*) "(summing all coupling-power combinations)"
write(*,*) "rval(1) (tree_loop, double pole) = ", rval(1)
write(*,*) "rval(2) (tree_loop, single pole) = ", rval(2)
write(*,*) "rval(3) (tree_loop, finite)      = ", rval(3)
write(*,*) "rval(4) (tree_tree, finite)      = ", rval(4)
write(*,*) "acc = ", acc
write(*,*) ""

! Compute and print color-correlated Born MEs if requested
ccyesno = 0
if ( argc == 5 ) then
  call get_command_argument(5,ccyesnoarg)
  ccyesnoarg = trim(adjustl(ccyesnoarg))
  read(ccyesnoarg,*) ccyesno
  if ( ccyesno == 1 ) then
    ! NLOX_OLP_EvalSubProcess_CC throws a warning if it is used for tree_loop.
    call NLOX_OLP_EvalSubProcess_CC(isub, typ, ltyp, trim(adjustl(cp)), lcp, pp, next, mu, rvalcc, acccc)

    write(*,*) "Sub-process ID ", isub, &
               ", coupling-power combination ", trim(adjustl(cp)), &
               ", at a fixed scale of ", mu, " GeV:"
    write(*,*) "(Born ME and color-correlated Born MEs)"
    write(*,*) "rvalcc(1) (tree_tree, finite) = ", rvalcc(1)
    cccounter = 2
    do j=1,next
      do k=j+1,next
        ! print *, "rval(",cccounter,") (tree_T",j,"T",k,"_tree, finite) = ", rvalcc(cccounter)
        write(*,*) "rval(",cccounter,") (tree_T",j,"T",k,"_tree, finite) = ", rvalcc(cccounter)
        cccounter=cccounter+1
      enddo
    enddo
    write(*,*) "acc = ", acccc
    write(*,*) ""
  endif
endif

end program ftest_process
