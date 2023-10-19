
if ( NOT BUILD_TYPE )
   message( WARNING "Setting CMAKE_BUILD_TYPE to default value." )
   set(BUILD_TYPE BIG)
endif()

if ( ${BUILD_TYPE} STREQUAL "PARALLEL" ) # compiler for parallel build
  set(ENV{FC} mpif90)
  set(CMAKE_Fortran_COMPILER mpif90)
  set(USER_Fortran_FLAGS "-cpp -ffree-form -ffree-line-length-none -fno-automatic")
  #set(USER_Fortran_FLAGS_RELEASE "-fconvert=little-endian -fallow-argument-mismatch -O3 -ffast-math -mtune=native -march=native")
  add_definitions(-DUSE_FFTW -DUSE_MPI -DUSE_MPI_IO)
  set(CMAKE_BUILD_TYPE RELEASE)
elseif(${BUILD_TYPE} STREQUAL "GPU" ) # Compiler for gpu acceleration
  set(ENV{FC} nvfortran)
  #set(CMAKE_Fortran_FLAGS "-acc=verystrict,gpu -target=gpu -Minfo=accel,inline -gpu=ccnative,lineinfo")
  #ccXY            Compile for compute capability X.Y; supported values: 35,50,60,61,62,70,72,75,80,86
  #set(CMAKE_Fortran_FLAGS "-acc=gpu -target=gpu -Minfo=accel,inline -gpu=ccnative,lineinfo -cpp")
  #set(CMAKE_Fortran_FLAGS "-acc=gpu -target=gpu -Mfree -Minfo=accel,inline -gpu=lineinfo,cc80 -cpp")
  set(USER_Fortran_FLAGS "-cpp -Mfree -Mbuiltin -Minfo=accel,inline -acc=gpu -gpu=lineinfo,cc80,fastmath")
  add_definitions(-DNO_ASSUMED_RANKS -DUSE_FFTW)
  add_definitions(-D_DEBUG )
  set(CMKAE_BUILD_TYPE DEBUG)


else() # compiler for serial build
  set(ENV{FC} gfortran)
  set(CMAKE_Fortran_COMPILER gfortran)
  set(USER_Fortran_FLAGS "-cpp -ffree-form -ffree-line-length-none -fno-automatic")
  add_definitions(-DUSE_FFTW)

  if    ( ${BUILD_TYPE} STREQUAL "BIG" )
	  #set(USER_Fortran_FLAGS_RELEASE "-fconvert=big-endian -fallow-argument-mismatch -ffpe-summary=none -O3 -ffast-math -mtune=native -march=native")
    set(CMAKE_BUILD_TYPE RELEASE)

  elseif( ${BUILD_TYPE} STREQUAL "LITTLE" )
	  #set(USER_Fortran_FLAGS_RELEASE "-fconvert=little-endian -fallow-argument-mismatch -ffpe-summary=none -O3 -ffast-math -mtune=native -march=native")
    set(CMAKE_BUILD_TYPE RELEASE)

  else()
    set(USER_Fortran_FLAGS_DEBUG "-O0 -p -ggdb -Wall -fbacktrace -ffpe-trap=invalid,zero,overflow,underflow,precision,denormal")
    #set(USER_Fortran_FLAGS_DEBUG "-O0 -p -ggdb -Wall -fbacktrace -ffpe-trap=invalid")
    #set(USER_Fortran_FLAGS_DEBUG "-O0 -ggdb -Wall -fbacktrace -fconvert=little-endian -fallow-argument-mismatch -ffpe-trap=invalid,zero,overflow")
    add_definitions(-D_DEBUG)
    set(CMAKE_BUILD_TYPE DEBUG)

  endif()

endif()

#set(FFTW_INCLUDE_DIR   "/usr/local/include")
#set(FFTW_LIB           "/usr/local/lib/libfftw3.a")
#set(FFTW_INCLUDE_DIR   "/home/m/m300912/local_include/include")
#set(FFTW_LIB           "/home/m/m300912/local_include/lib/libfftw.a")
#set(FFTW_LIB           "-lfftw3")

if(${BUILD_TYPE} STREQUAL "GPU" ) # Compiler for gpu acceleration
  set(FFTW_INCLUDE_DIR   "/home/m/m300912/spack/install/fftw-3.3.10-3un3vq/include/")
  set(FFTW_LIB           "/home/m/m300912/spack/install/fftw-3.3.10-3un3vq/lib/libfftw3.a")

  add_definitions(-DUSE_NETCDF)
  set(NC_INCLUDE_DIR     "/sw/spack-levante/netcdf-fortran-4.5.3-ojzrgm/include")
  set(NC_LIB             "-I/sw/spack-levante/netcdf-fortran-4.5.3-ojzrgm/include \
                       -L/sw/spack-levante/netcdf-fortran-4.5.3-ojzrgm/lib -lnetcdff \
                       -Wl,-rpath,/sw/spack-levante/netcdf-fortran-4.5.3-ojzrgm/lib")
else()
  set(FFTW_INCLUDE_DIR   "/sw/spack-levante/fftw-3.3.10-fnfhvr/include/")
  set(FFTW_LIB           "/sw/spack-levante/fftw-3.3.10-fnfhvr/lib/libfftw3.a")

  add_definitions(-DUSE_NETCDF)
  set(NC_INCLUDE_DIR     "/sw/spack-levante/netcdf-fortran-4.5.3-jlxcfz/include")
  set(NC_LIB             "-I/sw/spack-levante/netcdf-fortran-4.5.3-jlxcfz/include \
                        -L/sw/spack-levante/netcdf-fortran-4.5.3-jlxcfz/lib -lnetcdff \
                        -Wl,-rpath,/sw/spack-levante/netcdf-fortran-4.5.3-jlxcfz/lib")
endif()

set(INCLUDE_DIRS ${FFTW_INCLUDE_DIR})
set(LIBS ${FFTW_LIB})

set(INCLUDE_DIRS ${INCLUDE_DIRS} ${NC_INCLUDE_DIR})
set(LIBS ${LIBS} ${NC_LIB})
