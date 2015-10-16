!----------------------------------------------------------------------------------------------------------------------------------
! SPHERA (Smoothed Particle Hydrodynamics research software; mesh-less Computational Fluid Dynamics code).
! Copyright 2005-2015 (RSE SpA -formerly ERSE SpA, formerly CESI RICERCA, formerly CESI-) 
!      
!     
!   
!      
!  

! This file is part of SPHERA.
!  
!  
!  
!  
! SPHERA is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
!  
!  
!  
!----------------------------------------------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------------------------------------------
! Program unit: viscapp 
! Description: Constitutive equation with tuninig parameters (validated in Manenti et al.,2012,JHE).        
!----------------------------------------------------------------------------------------------------------------------------------

subroutine viscapp
!------------------------
! Modules
!------------------------ 
use Static_allocation_module
use Hybrid_allocation_module
use Dynamic_allocation_module
!------------------------
! Declarations
!------------------------
implicit none
double precision,parameter :: alfa = 1.0d0
integer(4) :: npi
double precision :: mu, mumax, secinv,cuin, smalen, smalenq, visc1, visc2 
character(100),external :: lcase
!------------------------
! Explicit interfaces
!------------------------
!------------------------
! Allocations
!------------------------
!------------------------
! Initializations
!------------------------
!------------------------
! Statements
!------------------------
if (.not. diffusione) then
!$omp parallel do default(none)                                                &
!$omp private(npi,visc1,smalen,smalenq,visc2,secinv,cuin,mu,mumax)             &
!$omp shared(nag,pg,Med,Domain,it_corrente)
   do npi=1,nag
      if ((pg(npi)%cella==0).or.(pg(npi)%vel_type/="std")) cycle
      select case (Med(pg(npi)%imed)%tipo)
         case ( "liquid  " )
            pg(npi)%visc = Med(pg(npi)%imed)%visc
         case ( "gas     " )
            pg(npi)%visc = Med(pg(npi)%imed)%visc
         case ( "smagorin" )  
            visc1   = Med(pg(npi)%imed)%visc 
            smalen  = Med(pg(npi)%imed)%Cs * Domain%h               
            smalenq = smalen * smalen  
            visc2   = smalenq * two * pg(npi)%secinv
            pg(npi)%visc = visc1 + visc2 
         case ( "general " )
            secinv = two * pg(npi)%secinv
            cuin = Med(pg(npi)%imed)%cuin
            mu = Med(pg(npi)%imed)%taucri / (secinv + 0.0001d0) +              &
                 Med(pg(npi)%imed)%cons * ((secinv + 0.0001d0) ** (cuin - one))
            mumax = Med(pg(npi)%imed)%mumx
            pg(npi)%visc = min(mumax,mu) / pg(npi)%dens
! Part to check: start
            if (pg(npi)%state=="sol") then
! During the first NIterSol steps, the mixture particles do not move
               if (((pg(npi)%visc/=mumax/pg(npi)%dens).and.                    &
                  (it_corrente>Med(pg(npi)%imed)%NIterSol)).or.                &
                  (pg(npi)%kodvel==2)) then
                  pg(npi)%state = "flu"
               end if
            end if
! Part to check: end
         case ( "granular" )
            pg(npi)%visc = pg(npi)%mu / pg(npi)%dens
         case default
      end select
   end do
!$omp end parallel do
   else if (diffusione) then
!$omp parallel do default(none) private(npi) shared(nag,pg,Med)
      do npi=1,nag
         if ((pg(npi)%cella==0).or.(pg(npi)%vel_type/="std")) cycle
         if ((index(Med(1)%tipo,"liquid")>0).and.                              &
            (index(Med(2)%tipo,"liquid")>0)) then
            pg(npi)%visc = pg(npi)%VolFra*Med(2)%visc + (one -                 &
                           pg(npi)%VolFra)*Med(1)%visc
            else if ((index(Med(1)%tipo,"liquid")>0).and.                      &
               (index(Med(2)%tipo,"granular")>0)) then
               if ((pg(npi)%VolFra>=VFmn).and.(pg(npi)%VolFra<=VFmx)) then
                  pg(npi)%visc = pg(npi)%VolFra*Med(2)%visc + (one -           &
                                 pg(npi)%VolFra)*Med(1)%visc
                  else if (pg(npi)%VolFra<VFmn) then
                     pg(npi)%visc = Med(1)%visc
                     else if (pg(npi)%VolFra<VFmx) then
                        pg(npi)%visc = Med(2)%visc
               end if
         end if
      end do
!$omp end parallel do
end if
!------------------------
! Deallocations
!------------------------
return
end subroutine viscapp

