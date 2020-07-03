      program main

      INTEGER,PARAMETER :: zd1=26,IX=144,IY=96,zd18=27

c  input data
      real rht_cloud(ix,iy,zd18),rht_base_sw(ix,iy,zd18)
      real rht_base_lw(ix,iy,zd18),rht_base(ix,iy,zd18)
      real rht_warm(ix,iy,zd18),rht_warm_sw(ix,iy,zd18)
      real rht_warm_lw(ix,iy,zd18),rht_o3(ix,iy,zd18)
      real rht_wv(IX,IY,zd18),rht_albedo(IX,IY,zd18)
      real rht_cloud_sw(ix,iy,zd18),rht_cloud_lw(ix,iy,zd18)
      real rht_solar(ix,iy,zd18),rht_co2(ix,iy,zd18)
      real lhflx_base(ix,iy),shflx_base(ix,iy)
      real lhflx_warm(ix,iy),shflx_warm(ix,iy)

!forcing output
      real fc_dyn(ix,iy,zd18),fc_cloud(ix,iy,zd18)
      real fc_wv(ix,iy,zd18),fc_albedo(ix,iy,zd18)
      real fc_o3(ix,iy,zd18),fc_co2(ix,iy,zd18)
      real fc_cloud_sw(ix,iy,zd18),fc_cloud_lw(ix,iy,zd18)
      real fc_solar(ix,iy,zd18)
      real fc_atm_dyn(ix,iy,zd18),fc_sfc_dyn(ix,iy,zd18)
      real fc_lhflx(ix,iy,zd18),fc_shflx(ix,iy,zd18)

!partial temp. output
      real dt_wv(ix,iy,zd18),dt_albedo(ix,iy,zd18)
      real dt_dyn(ix,iy,zd18),dt_shflx(ix,iy,zd18)
      real dt_cloud(ix,iy,zd18),dt_cloud_sw(ix,iy,zd18)
      real dt_cloud_lw(ix,iy,zd18),dt_lhflx(ix,iy,zd18)
      real dt_o3(ix,iy,zd18),dt_ocean(ix,iy,zd18)
      real dt_co2(ix,iy,zd18),dt_solar(ix,iy,zd18)
      real dt_atm_dyn(ix,iy,zd18),dt_sfc_dyn(ix,iy,zd18)

      real drdt(100,100),fc(100),x(ix,iy)


       open ( unit = 11, file = './baseline_radranc_1.grd',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 12, file = './albedo_radranc_1.grd',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 13, file = './wv_radranc_1.grd',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 14, file = './cloud_radranc_1.grd',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 15, file = './co2_radranc_1.grd',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 16, file = './o3_radranc_1.grd',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 17, file = './solar_radranc_1.grd',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 18, file = './warm_radranc_1.grd',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 21, file = 
     & './drdt_ranc_1.dat',
     & form='unformatted', access='direct',recl=100*100)

       open ( unit = 31, file = '../data/raw/slhf_base.dat',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 32, file = '../data/raw/slhf_warm.dat',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 33, file = '../data/raw/sshf_base.dat',
     & form='unformatted', access='direct',recl=IX*IY )

       open ( unit = 34, file = '../data/raw/sshf_warm.dat',
     & form='unformatted', access='direct',recl=IX*IY )

       open(51,file = './partial_T_1.grd',
     & form='unformatted', access = 'direct', recl = IX*IY)

       open(52,file = './forcing_1.grd',
     & form='unformatted', access = 'direct', recl = IX*IY)

       nt = 1
       xnt= float(nt)

       rht_base(:,:,:)=0.0
       rht_base_sw(:,:,:)=0.0
       rht_base_lw(:,:,:)=0.0       
       rht_o3(:,:,:)=0.0
       rht_wv(:,:,:)=0.0
       rht_albedo(:,:,:)=0.0
       rht_cloud(:,:,:)=0.0
       rht_co2(:,:,:)=0.0
       rht_solar(:,:,:)=0.0
       rht_warm(:,:,:)=0.0
       rht_warm_sw(:,:,:)=0.0
       rht_warm_lw(:,:,:)=0.0
       rht_cloud_sw(:,:,:)=0.0
       rht_cloud_lw(:,:,:)=0.0
       
       do 100 it = 1, nt
          irec=(it-1)*7*zd18
       do l = 1, zd18

          irec=irec+1
          read(11,rec=irec)x !base
          do i = 1, ix
             do j = 1, iy
                rht_base(i,j,l)=rht_base(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(12,rec=irec)x !albedo
          do i = 1, ix
             do j = 1, iy
                rht_albedo(i,j,l)=rht_albedo(i,j,l)+x(i,j)!/xnt
             enddo
          enddo          

          read(13,rec=irec)x    !wv
          do i = 1, ix
             do j = 1, iy
                rht_wv(i,j,l)=rht_wv(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(14,rec=irec)x !cloud
          do i = 1, ix
             do j = 1, iy
                rht_cloud(i,j,l)=rht_cloud(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(15,rec=irec)x !co2
          do i = 1, ix
             do j = 1, iy
                rht_co2(i,j,l)=rht_co2(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(16,rec=irec)x !o3
          do i = 1, ix
             do j = 1, iy
                rht_o3(i,j,l)=rht_o3(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(17,rec=irec)x !solar
          do i = 1, ix
             do j = 1, iy
                rht_solar(i,j,l)=rht_solar(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(18,rec=irec)x !2c02
          do i = 1, ix
             do j = 1, iy
                rht_warm(i,j,l)=rht_warm(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

       enddo

       do l = 1, zd18

          irec=irec+1
          read(11,rec=irec)x !base
          do i = 1, ix
             do j = 1, iy
                rht_base_sw(i,j,l)=rht_base_sw(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(14,rec=irec)x ! clouds
          do i = 1, ix
             do j = 1, iy
                rht_cloud_sw(i,j,l)=rht_cloud_sw(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(18,rec=irec)x !warm
          do i = 1, ix
             do j = 1, iy
                rht_warm_sw(i,j,l)=rht_warm_sw(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

       enddo

       do l = 1, zd18

          irec=irec+1
          read(11,rec=irec)x
          do i = 1, ix
             do j = 1, iy
                rht_base_lw(i,j,l)=rht_base_lw(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(14,rec=irec)x ! clouds
          do i = 1, ix
             do j = 1, iy
                rht_cloud_lw(i,j,l)=rht_cloud_lw(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

          read(18,rec=irec)x !warm
          do i = 1, ix
             do j = 1, iy
                rht_warm_lw(i,j,l)=rht_warm_lw(i,j,l)+x(i,j)!/xnt
             enddo
          enddo

       enddo

 100   continue

       read(31,rec=1)lhflx_base
       read(32,rec=1)lhflx_warm
       read(33,rec=1)shflx_base
       read(34,rec=1)shflx_warm

       print*, "end of 100 loop"
       print*, "end of input"

       do 2000 j = 1,IY
       do 2000 i = 1,IX
          
          irec=(j-1)*ix+i
          
          do k = 1,zd18
              n1 = rht_base(i,j,k).eq.(-999.0)
              n2 = rht_base(i,j,k).eq.(-999.0)
c              n2 = rht_warm(i,j,k).eq.(-999.0)
              if(n1.or.n2)then
                  exit
              end if
          end do
          if(k.eq.28)then
              k=k-1
c              print*,i,j,"k=28"
          end if
          
          nv1=k
          nv=nv1-1  

c          print*,i,j,irec,nv1
c          pause
          read(21,rec=irec)drdt
c          print*,drdt(1:100,1)
c          print*,drdt(1:100,10)
c          print*,drdt(1:100,26)
c          print*,rht_base(i,j,:)

          if(isnan(drdt(1,1)))then
             print*,"drdt in ",i,j,"is NaN"
             irec=irec-1 !drdt_ran has infinite values this location
             read(21,rec=irec)drdt
c              goto 2000 
             PAUSE
          endif
c          exit

          rht_base(i,j,nv1)    =rht_base(i,j,zd18)
          rht_base_sw(i,j,nv1) =rht_base_sw(i,j,zd18)
          rht_base_lw(i,j,nv1) =rht_base_lw(i,j,zd18)
          rht_albedo(i,j,nv1)  =rht_albedo(i,j,zd18)
          rht_wv(i,j,nv1)      =rht_wv(i,j,zd18)
          rht_cloud(i,j,nv1)   =rht_cloud(i,j,zd18)
          rht_cloud_sw(i,j,nv1)=rht_cloud_sw(i,j,zd18)
          rht_cloud_lw(i,j,nv1)=rht_cloud_lw(i,j,zd18)
          rht_co2(i,j,nv1)     =rht_co2(i,j,zd18)
          rht_o3(i,j,nv1)      =rht_o3(i,j,zd18)
          rht_solar(i,j,nv1)   =rht_solar(i,j,zd18)
          rht_warm(i,j,nv1)    =rht_warm(i,j,zd18)
          rht_warm_sw(i,j,nv1) =rht_warm_sw(i,j,zd18)
          rht_warm_lw(i,j,nv1) =rht_warm_lw(i,j,zd18)

c          if(j .eq. 2 .and. i .eq. 76)then
c             irec=irec-1 !drdt_ran has infinite values at this location
c             read(21,rec=irec)drdt
c          endif
c          if(j .eq. 2 .and. i .eq. 77)then
c              irec=irec-2 !drdt_ran has infinite values at this
c              read(21,rec=irec)drdt
c          endif
c          print*,irec

          do k = 1, nv1
             fc(k)=rht_albedo(i,j,k)-rht_base(i,j,k)
             fc_albedo(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_albedo(i,j,k)=fc(k)
          enddo

c          print*,"after albedo"
          do k = 1, nv1
             fc(k)=rht_wv(i,j,k)-rht_base(i,j,k)
             fc_wv(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_wv(i,j,k)=fc(k)
          enddo

          do k = 1, nv1
             fc(k)=rht_cloud(i,j,k)-rht_base(i,j,k)
             fc_cloud(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_cloud(i,j,k)=fc(k)
          enddo

c          print*, "after cloud"
          do k = 1, nv1
             fc(k)=rht_cloud_sw(i,j,k)-rht_base_sw(i,j,k)
             fc_cloud_sw(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_cloud_sw(i,j,k)=fc(k)
          enddo

          do k = 1, nv1
             fc(k)=rht_cloud_lw(i,j,k)-rht_base_lw(i,j,k)
             fc_cloud_lw(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_cloud_lw(i,j,k)=fc(k)
          enddo

          do k = 1, nv1
             fc(k)=rht_co2(i,j,k)-rht_base(i,j,k)
             fc_co2(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_co2(i,j,k)=fc(k)
          enddo

          do k = 1, nv1
             fc(k)=rht_o3(i,j,k)-rht_base(i,j,k)
             fc_o3(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_o3(i,j,k)=fc(k)
          enddo

          do k = 1, nv1
             fc(k)=rht_solar(i,j,k)-rht_base(i,j,k)
             fc_solar(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_solar(i,j,k)=fc(k)
          enddo

          do k = 1, nv1
             fc(k)=-(rht_warm(i,j,k)-rht_base(i,j,k))
             fc_dyn(i,j,k)=fc(k)
          enddo
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_dyn(i,j,k)=fc(k)
          enddo

          do k = 1, nv
             fc(k)=-(rht_warm(i,j,k)-rht_base(i,j,k))
             fc_atm_dyn(i,j,k)=fc(k)
          enddo
          fc_atm_dyn(i,j,nv1)=0
          fc(nv1) = fc_atm_dyn(i,j,nv1)
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_atm_dyn(i,j,k)=fc(k)
          enddo

          do k = 1, nv1
             fc(k)=0
             fc_sfc_dyn(i,j,k)=fc(k)
          enddo
          fc_sfc_dyn(i,j,nv1)=-(rht_warm(i,j,nv1)-rht_base(i,j,nv1))
     &                        -(shflx_warm(i,j)-shflx_base(i,j))
     &                        -(lhflx_warm(i,j)-lhflx_base(i,j))      
          fc(nv1)=fc_sfc_dyn(i,j,nv1)
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_sfc_dyn(i,j,k)=fc(k)
          enddo
          
          do k = 1, nv1
             fc(k)=0
             fc_shflx(i,j,k)=fc(k)
          enddo
          fc_shflx(i,j,nv1)=shflx_warm(i,j)-shflx_base(i,j)
          fc(nv1)=fc_shflx(i,j,nv1)
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_shflx(i,j,k)=fc(k)
          enddo
           
          do k = 1, nv1
             fc(k)=0
             fc_lhflx(i,j,k)=fc(k)
          enddo
          fc_lhflx(i,j,nv1)=lhflx_warm(i,j)-lhflx_base(i,j)
          fc(nv1)=fc_lhflx(i,j,nv1)
          call delt_gauss(drdt,fc,nv1)
          do k = 1, nv1
             dt_lhflx(i,j,k)=fc(k)
          enddo

           dt_albedo(i,j,zd18)=dt_albedo(i,j,nv1)
           fc_albedo(i,j,zd18)=fc_albedo(i,j,nv1)
           dt_wv(i,j,zd18)=dt_wv(i,j,nv1)
           fc_wv(i,j,zd18)=fc_wv(i,j,nv1)          
           dt_cloud(i,j,zd18)=dt_cloud(i,j,nv1)
           fc_cloud(i,j,zd18)=fc_cloud(i,j,nv1)
           dt_cloud_sw(i,j,zd18)=dt_cloud_sw(i,j,nv1)
           fc_cloud_sw(i,j,zd18)=fc_cloud_sw(i,j,nv1)
           dt_cloud_lw(i,j,zd18)=dt_cloud_lw(i,j,nv1)
           fc_cloud_lw(i,j,zd18)=fc_cloud_lw(i,j,nv1)
           dt_co2(i,j,zd18)=dt_co2(i,j,nv1)
           fc_co2(i,j,zd18)=fc_co2(i,j,nv1)
           dt_o3(i,j,zd18)=dt_o3(i,j,nv1)
           fc_o3(i,j,zd18)=fc_o3(i,j,nv1)
           dt_solar(i,j,zd18)=dt_solar(i,j,nv1)
           fc_solar(i,j,zd18)=fc_solar(i,j,nv1)
           dt_dyn(i,j,zd18)=dt_dyn(i,j,nv1)
           fc_dyn(i,j,zd18)=fc_dyn(i,j,nv1)
           dt_atm_dyn(i,j,zd18)=dt_atm_dyn(i,j,nv1)
           fc_atm_dyn(i,j,zd18)=fc_atm_dyn(i,j,nv1)
           dt_sfc_dyn(i,j,zd18)=dt_sfc_dyn(i,j,nv1)
           fc_sfc_dyn(i,j,zd18)=fc_sfc_dyn(i,j,nv1)
           dt_shflx(i,j,zd18)=dt_shflx(i,j,nv1)
           fc_shflx(i,j,zd18)=fc_shflx(i,j,nv1)
           dt_lhflx(i,j,zd18)=dt_lhflx(i,j,nv1)
           fc_lhflx(i,j,zd18)=fc_lhflx(i,j,nv1)
           IF(nv.LT.zd1) then
             do l=nv1,zd1
                dt_albedo(i,j,l)=-999
                dt_wv(i,j,l)=-999
                dt_co2(i,j,l)=-999
                dt_cloud(i,j,l)=-999
                dt_cloud_sw(i,j,l)=-999
                dt_cloud_lw(i,j,l)=-999
                dt_o3(i,j,l)=-999
                dt_solar(i,j,l)=-999
                dt_dyn(i,j,l)=-999
                dt_atm_dyn(i,j,l)=-999
                dt_sfc_dyn(i,j,l)=-999
                dt_shflx(i,j,l)=-999
                dt_lhflx(i,j,l)=-999
                fc_albedo(i,j,l)=-999
                fc_wv(i,j,l)=-999
                fc_co2(i,j,l)=-999
                fc_cloud(i,j,l)=-999
                fc_cloud_sw(i,j,l)=-999
                fc_cloud_lw(i,j,l)=-999
                fc_o3(i,j,l)=-999
                fc_solar(i,j,l)=-999
                fc_dyn(i,j,l)=-999
                fc_atm_dyn(i,j,l)=-999
                fc_sfc_dyn(i,j,l)=-999
                fc_shflx(i,j,l)=-999
                fc_lhflx(i,j,l)=-999
             enddo
          ENDIF
 2000  continue

c       do k = 1, nv1
c          dt_external(256,38,k)=dt_external(255,38,k)
c       enddo
       !do know why only dt_external at this point is too large
       !other dt don't have the problem => drdt at this point is
       !ok.  also fc_external at this point is also okay.
       !the errors are at stratosphere. (only dt not fc)   

       irec=1
       call out3d(dt_albedo,ix,iy,zd18,51,irec)
       call out3d(fc_albedo,ix,iy,zd18,52,irec)
       irec=irec+zd18
       
       call out3d(dt_wv,ix,iy,zd18,51,irec)
       call out3d(fc_wv,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_cloud,ix,iy,zd18,51,irec)
       call out3d(fc_cloud,ix,iy,zd18,52,irec)
       irec=irec+zd18
  
       call out3d(dt_cloud_sw,ix,iy,zd18,51,irec)
       call out3d(fc_cloud_sw,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_cloud_lw,ix,iy,zd18,51,irec)
       call out3d(fc_cloud_lw,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_co2,ix,iy,zd18,51,irec)
       call out3d(fc_co2,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_o3,ix,iy,zd18,51,irec)
       call out3d(fc_o3,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_solar,ix,iy,zd18,51,irec)
       call out3d(fc_solar,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_dyn,ix,iy,zd18,51,irec)
       call out3d(fc_dyn,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_atm_dyn,ix,iy,zd18,51,irec)
       call out3d(fc_atm_dyn,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_sfc_dyn,ix,iy,zd18,51,irec)
       call out3d(fc_sfc_dyn,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_shflx,ix,iy,zd18,51,irec)
       call out3d(fc_shflx,ix,iy,zd18,52,irec)
       irec=irec+zd18

       call out3d(dt_lhflx,ix,iy,zd18,51,irec)
       call out3d(fc_lhflx,ix,iy,zd18,52,irec)
       
       end

      subroutine out3d(out,ii,jj,kk,iunit,irec0)
      real out(ii,jj,kk)
      real x(ii,jj)
      integer irec

      irec=irec0
      do k = 1,kk
         do i = 1, ii
            do j = 1, jj
               x(i,j)=out(i,j,k)
            enddo 
         enddo
         write(iunit,rec=irec)x
         irec=irec+1
      enddo
      return  
      end  

      subroutine delt_gauss(rad_kern,frc,nv1)
c     calculate delt T (n) by individual forcings by
c     solving the matrix equation
c     frc : input as forcing and out as delt T

      real rad_kern(100,100),frc(100)
      real drdt(nv1,nv1),frc_def(nv1)

      do i=1,nv1
         frc_def(i)=frc(i)
         do j=1,nv1
            drdt(i,j)=rad_kern(i,j)
         enddo
      enddo
      
      call gaussj(drdt,nv1,nv1,frc_def,1,1)
      do l = 1, nv1
         frc(l)=frc_def(l)
      enddo

      return
      end

      SUBROUTINE gaussj(a,n,np,b,m,mp)
      INTEGER m,mp,n,np,NMAX
      REAL a(np,np),b(np,mp)
      PARAMETER (NMAX=50)
      INTEGER i,icol,irow,j,k,l,ll,indxc(NMAX),
     &        indxr(NMAX),ipiv(NMAX)
      REAL  big,dum,pivinv

      do j=1,n
         ipiv(j)=0
      enddo

      do i=1,n
         big=0.
         do j=1,n
            if(ipiv(j).ne.1) then
              do k=1,n
                 if(ipiv(k).eq.0) then
                  if(abs(a(j,k)).ge.big) then
                     big=abs(a(j,k))
                     irow=j
                     icol=k
                  endif
                 endif
              enddo
            endif
         enddo
         ipiv(icol)=ipiv(icol)+1

         if(irow.ne.icol) then
           do l=1,n
              dum=a(irow,l)
              a(irow,l)=a(icol,l)
              a(icol,l)=dum
           enddo
           do l=1,m
              dum=b(irow,l)
              b(irow,l)=b(icol,l)
              b(icol,l)=dum
           enddo
         endif

         indxr(i)=irow
         indxc(i)=icol

         if(a(icol,icol).eq.0.) a(icol,icol)= -3.0517578E-05 ! pause

         pivinv=1./a(icol,icol)
         a(icol,icol)=1.

         do l=1,n
            a(icol,l)=a(icol,l)*pivinv
         enddo

         do l=1,m
            b(icol,l)=b(icol,l)*pivinv
         enddo

         do ll=1,n
            if(ll.ne.icol) then
              dum=a(ll,icol)
              a(ll,icol)=0.
              do l=1,n
               a(ll,l)=a(ll,l)-a(icol,l)*dum
              enddo

              do l=1,m
                b(ll,l)=b(ll,l)-b(icol,l)*dum
              enddo
            endif
          enddo
      enddo

      do l=n,1,-1
         if(indxr(l).ne.indxc(l)) then
           do k=1,n
              dum=a(k,indxr(l))
              a(k,indxr(l))=a(k,indxc(l))
              a(k,indxc(l))=dum
           enddo
         endif
      enddo
      return
      end
