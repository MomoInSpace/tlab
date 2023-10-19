if ( NOT BUILD_TYPE )
   message( WARNING "Setting CMAKE_BUILD_TYPE to default value." )
   set(BUILD_TYPE BIG)
endif()

# We always use fftw and netcdf
add_definitions(-DUSE_FFTW -DUSE_NETCDF)

if ( ${BUILD_TYPE} STREQUAL "PARALLEL" ) # compiler for parallel build
  set(ENV{FC} mpif90)
  set(CMAKE_Fortran_COMPILER mpif90)
  set(USER_Fortran_FLAGS "-cpp -ffree-form -ffree-line-length-none -fno-automatic")
  #set(USER_Fortran_FLAGS_RELEASE "-fconvert=little-endian -fallow-argument-mismatch -O3 -ffast-math -mtune=native -march=native")
  set(CMAKE_BUILD_TYPE RELEASE)
  add_definitions(-DUSE_MPI -DUSE_MPI_IO)
elseif(${BUILD_TYPE} STREQUAL "GPU" ) # Compiler for gpu acceleration
  # On levante use the module nvhpc/22.5-gcc-11.2.0
  set(ENV{FC} nvfortran)
  set(CMAKE_Fortran_COMPILER nvfortran)
  # gpu=fastmath can be removed for more accuracy
  set(USER_Fortran_FLAGS "-cpp -Mfree -Mbuiltin -Minfo=accel,inline -acc=gpu,verystrict -gpu=lineinfo,cc80,fastmath")
  set(CMKAE_BUILD_TYPE DEBUG)
  add_definitions(-DNO_ASSUMED_RANKS) # nvfortran doesn't support assumed ranks yet
  add_definitions(-D_DEBUG )


else() # compiler for serial build
  set(ENV{FC} gfortran)
  set(CMAKE_Fortran_COMPILER gfortran)
  set(USER_Fortran_FLAGS "-cpp -ffree-form -ffree-line-length-none -fno-automatic")

  if    ( ${BUILD_TYPE} STREQUAL "BIG" )
    set(CMAKE_BUILD_TYPE RELEASE)
	#set(USER_Fortran_FLAGS_RELEASE "-fconvert=big-endian -fallow-argument-mismatch -ffpe-summary=none -O3 -ffast-math -mtune=native -march=native")

  elseif( ${BUILD_TYPE} STREQUAL "LITTLE" )
    set(CMAKE_BUILD_TYPE RELEASE)
	#set(USER_Fortran_FLAGS_RELEASE "-fconvert=big-endian -fallow-argument-mismatch -ffpe-summary=none -O3 -ffast-math -mtune=native -march=native")

  else()
    set(USER_Fortran_FLAGS_DEBUG "-O0 -p -ggdb -Wall -fbacktrace -ffpe-trap=invalid,zero,overflow,underflow,precision,denormal")
    #set(USER_Fortran_FLAGS_DEBUG "-O0 -p -ggdb -Wall -fbacktrace -ffpe-trap=invalid")
    #set(USER_Fortran_FLAGS_DEBUG "-O0 -ggdb -Wall -fbacktrace -fconvert=little-endian -fallow-argument-mismatch -ffpe-trap=invalid,zero,overflow")
    set(CMAKE_BUILD_TYPE DEBUG)
    add_definitions(-D_DEBUG)

  endif()

endif()

# As mpif90 uses gfortran as backbone, we only need to provide two sets of libraries
if(${BUILD_TYPE} STREQUAL "GPU" ) # Compiler for gpu acceleration
  # fftw needs to be installed with the command
  # spack install fftw %nvhpc@22.5 ^openmpi%nvhpc ^/mviuwj
  # and than linked to the directory
  set(FFTW_INCLUDE_DIR   "/home/m/m300912/spack/install/fftw-3.3.10-3un3vq/include/")
  set(FFTW_LIB           "/home/m/m300912/spack/install/fftw-3.3.10-3un3vq/lib/libfftw3.a")

  set(NC_INCLUDE_DIR     "/sw/spack-levante/netcdf-fortran-4.5.3-ojzrgm/include")
  set(NC_LIB             "-I/sw/spack-levante/netcdf-fortran-4.5.3-ojzrgm/include \
                       -L/sw/spack-levante/netcdf-fortran-4.5.3-ojzrgm/lib -lnetcdff \
                       -Wl,-rpath,/sw/spack-levante/netcdf-fortran-4.5.3-ojzrgm/lib")
else()
  set(FFTW_INCLUDE_DIR   "/sw/spack-levante/fftw-3.3.10-fnfhvr/include/")
  set(FFTW_LIB           "/sw/spack-levante/fftw-3.3.10-fnfhvr/lib/libfftw3.a")

  set(NC_INCLUDE_DIR     "/sw/spack-levante/netcdf-fortran-4.5.3-jlxcfz/include")
  set(NC_LIB             "-I/sw/spack-levante/netcdf-fortran-4.5.3-jlxcfz/include \
                        -L/sw/spack-levante/netcdf-fortran-4.5.3-jlxcfz/lib -lnetcdff \
                        -Wl,-rpath,/sw/spack-levante/netcdf-fortran-4.5.3-jlxcfz/lib")
endif()

# Including fftw
set(INCLUDE_DIRS ${FFTW_INCLUDE_DIR})
set(LIBS ${FFTW_LIB})

# Including netcdf
set(INCLUDE_DIRS ${INCLUDE_DIRS} ${NC_INCLUDE_DIR})
set(LIBS ${LIBS} ${NC_LIB})
