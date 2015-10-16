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
! Program unit: ReadInputDrawOptions                       
! Description:                        
!----------------------------------------------------------------------------------------------------------------------------------

subroutine ReadInputDrawOptions(ainp,comment,nrighe,ier,ninp,nout)
!------------------------
! Modules
!------------------------ 
use Static_allocation_module                            
use Hybrid_allocation_module
!------------------------
! Declarations
!------------------------
implicit none
integer(4) :: nrighe,ier, ninp,nout
character(1) :: comment
character(100) :: ainp
character(4) :: steptime
integer(4) :: ioerr
character(100) :: token
character(100),external :: lcase, GetToken
logical,external :: ReadCheck
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
call ReadRiga(ainp,comment,nrighe,ioerr,ninp)
if (.NOT.ReadCheck(ioerr,ier,nrighe,ainp,"DRAW OPTIONS DATA",ninp,nout)) return
do while (TRIM(lcase(ainp))/="##### end draw options #####")
   select case(lcase(GetToken(ainp,1,ioerr)))
      case("vtkconverter")
         token = lcase(GetToken(ainp,(2),ioerr))
         select case(token)
            case("any")
               token = lcase(GetToken(ainp,(3),ioerr))
               read (token,*,iostat=ioerr) freq_time
               if ((ncord>0).and.(nout>0)) write(nout,"(1x,a,1pe12.4,a)")      &
                  "VTKConversion any :",freq_time," seconds."
               val_time  = zero  
            case("at")
               token = lcase(GetToken(ainp,(3),ioerr))
               read (token,*,iostat=ioerr) freq_time
               if ((ncord>0).and.(nout>0)) write(nout,"(1x,a,1pe12.4,a)")      &
                  "VTKConversion at :",freq_time," second."
                  val_time  = freq_time
                  freq_time = -freq_time
            case("all")
               token = lcase(GetToken(ainp,(3),ioerr))
               read (token,*,iostat=ioerr) steptime
               if (steptime=='time') then
                  freq_time = Domain%memo_fr
                  val_time  = zero  
                  if ((ncord>0).and.(nout>0)) write(nout,"(1x,a,1pe12.4,a)")   &
                     "VTKConversion every :",freq_time," second."
                  elseif (steptime=='step') then
                     freq_time = zero
                     val_time  = const_m_9999
                     if ((ncord>0).and.(nout>0)) write(nout,"(1x,a)")          &
                        "VTKConversion all steps."
                     else
                        freq_time = Domain%memo_fr
                        val_time  = zero 
                        if ((ncord>0).and.(nout>0)) write(nout,                &
                           "(1x,a,1pe12.4,a)") "VTKConversion every :",        &
                           freq_time," second."
               endif
            case default
               freq_time = Domain%memo_fr
               val_time = zero
               if ((ncord)>0.and.(nout>0)) write(nout,"(1x,a,1pe12.4,a)")      &
                  "VTKConversion every :",freq_time," second."
         end select
         if ((ncord>0).and.(nout>0)) write(nout,"(1x,a)") " "
         vtkconv = .TRUE.
      case default
         ier = 4
         return
   end select
   call ReadRiga(ainp,comment,nrighe,ioerr,ninp)
   if (.NOT.ReadCheck(ioerr,ier,nrighe,ainp,"DRAW OPTIONS DATA",ninp,nout))    &
      return
enddo
!------------------------
! Deallocations
!------------------------
return
end subroutine ReadInputDrawOptions

