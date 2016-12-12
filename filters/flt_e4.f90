#include "types.h"

!########################################################################
!# HISTORY
!#
!# 2008/11/25 - J.P. Mellado
!#              Created
!#
!########################################################################
!# DESCRIPTION
!#
!# Explicit filter as described in Stolz's thesis.
!#
!########################################################################
SUBROUTINE FLT_E4(imax, jkmax, periodic, a, u, uf)

  IMPLICIT NONE

  LOGICAL periodic
  TINTEGER imax, jkmax
  TREAL, DIMENSION(jkmax,imax) :: u, uf
  TREAL, DIMENSION(imax,5)     :: a

! -------------------------------------------------------------------
  TINTEGER i, jk

! #######################################################################
! boundary points
! #######################################################################

! -------------------------------------------------------------------
! Periodic
! -------------------------------------------------------------------
  IF ( periodic ) THEN
     i = 1
     DO jk = 1,jkmax
        uf(jk,i) = a(i,1)*u(jk,imax-1) + a(i,2)*u(jk,imax) + a(i,3)*u(jk,i  ) &
                                       + a(i,4)*u(jk,i+1 ) + a(i,5)*u(jk,i+2) 
     ENDDO

     i = 2
     DO jk = 1,jkmax
        uf(jk,i) = a(i,1)*u(jk,imax) + a(i,2)*u(jk,i-1) + a(i,3)*u(jk,i  ) &
                                     + a(i,4)*u(jk,i+1) + a(i,5)*u(jk,i+2) 
     ENDDO

     i = imax-1
     DO jk = 1,jkmax
        uf(jk,i) = a(i,1)*u(jk,i-2) + a(i,2)*u(jk,i-1) + a(i,3)*u(jk,i) &
                                    + a(i,4)*u(jk,i+1) + a(i,5)*u(jk,1)
     ENDDO

     i = imax
     DO jk = 1,jkmax
        uf(jk,i) = a(i,1)*u(jk,i-2) + a(i,2)*u(jk,i-1) + a(i,3)*u(jk,i) &
                                    + a(i,4)*u(jk,1  ) + a(i,5)*u(jk,2) 
     ENDDO

! -------------------------------------------------------------------
! Nonperiodic
! -------------------------------------------------------------------
  ELSE
     i = 2
     DO jk = 1,jkmax
        uf(jk,1) = u(jk,1)
        uf(jk,i) =                    a(i,2)*u(jk,i-1) + a(i,3)*u(jk,i  ) &
                                    + a(i,4)*u(jk,i+1) + a(i,5)*u(jk,i+2) + a(i,1)*u(jk,i+3)
     ENDDO
     
     i = imax-1
     DO jk = 1,jkmax
        uf(jk,i) = a(i,1)*u(jk,i-2) + a(i,2)*u(jk,i-1) + a(i,3)*u(jk,i  )  &
                                    + a(i,4)*u(jk,i+1)                     + a(i,5)*u(jk,i-3)
        uf(jk,imax) = u(jk,imax)
     ENDDO
     
  ENDIF

! #######################################################################
! Interior points
! #######################################################################
  DO i = 3,imax-2
     DO jk = 1,jkmax
        uf(jk,i) = a(i,1)*u(jk,i-2) + a(i,2)*u(jk,i-1) + a(i,3)*u(jk,i  ) &
                                    + a(i,4)*u(jk,i+1) + a(i,5)*u(jk,i+2)
     ENDDO
  ENDDO

  RETURN
END SUBROUTINE FLT_E4
