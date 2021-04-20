*Beveridge & Nelson Multivariate Program
*This program using VAR-exact method
*this prorgam allows I(0) variables in the VAR - added january 31th
*Last update January 31th 2008
*by Freddy Rojas
*STATA 10

quie {
mata:
mata clear
real matrix m(real scalar num, real scalar lagsn)
{
n_eb=rowshape(st_matrix("e(b)"),num)'
F=J(1,rows(n_eb),0)
G=I(rows(n_eb)-1),J(rows(n_eb)-1,1,0)
F=F\G

for (i = 1; i <=cols(st_matrix("dym")); i++) {
F[lagsn*(i-1)+1,1...]=n_eb[1..rows(n_eb),i]'
}

h=J(lagsn*(cols(st_matrix("k"))),(cols(st_matrix("k"))),0)

for (j = 1; j <=cols(st_matrix("dym")); j++) {
h[lagsn*(j-1)+1,j]=1
}

B_t=editmissing(st_matrix("x_"),0);

c_tt=(-F*pinv(I(rows(n_eb))-F)*B_t')'
c_tt_h=h'*c_tt'
misv=J(1,num,.)  
c_tt_h=misv\c_tt_h'
return(c_tt_h)
}
mata mosave m(), replace
end

mata:
mata clear
real matrix av(real matrix nm)
{
f=mean(nm,1)
return(f)
}
mata mosave av(), replace
end mata

mata:
real matrix kn(real matrix nm, scalar nd)
{
v1=J(nd,1,1)
g=nm # v1
return(g)
}
mata mosave kn(), replace
end

}
***************** PROGRAM ********************

cap program drop bnmult
program define bnmult, rclass
version 10

syntax varlist(min=2) [, lags(real 1)] [ vario(varlist) ]
set more off
display in ye " This program performs Beveridge & Nelson multivariate filter "
display in ye " "
display in ye " Programmed by Freddy Rojas C."
display in ye " Universidad de Chile "
display in ye " freddyr@iadb.org "
display in gr " last update january 31th 2008"
display " "

quie {

if "`lags'" == " " {
	local lags = 1
}

local ncom: list sizeof varlist
local ncomio: list sizeof vario

tempvar t
gen `t'=_n
tsset `t'
local l_varlist " "

foreach var of varlist `varlist' {
	gen l_`var'=L.`var'
	local l_varlist = " `l_varlist' l_`var' "
}

mkmat `varlist', matrix(k) 
mkmat `l_varlist', matrix(l_k)

matrix yy = k
matrix dy=yy-l_k
matrix dy_=dy[2...,1..`ncom']

mata: st_matrix("m_dy",av(st_matrix("dy")))
mata: st_matrix("m",kn(st_matrix("m_dy"),st_nobs()-1))

matrix dym=dy_-m

if `ncomio' != 0 {
mkmat `vario', matrix(kio)
matrix k=k,kio
matrix kio=kio[2...,1..`ncomio']
mata: st_matrix("m_kio",av(st_matrix("kio")))
mata: st_matrix("mio",kn(st_matrix("m_kio"),st_nobs()-1))
matrix kio_=kio-mio
matrix dym=dym,kio_
}

svmat dym, names(rz___)

quie var rz___*, lags(1/`lags') noc

local i = 0
local j = 1

while `j' <= (`ncom'+`ncomio') {
	while `i' <= `lags'-1 {
	gen r__`i'_`j'=L`i'.rz___`j'
	local i=`i'+1
	}
local j=`j'+1
local i=0
}

local NN=_N-1
mkmat r__*, matrix(x_)
matrix x_=x_[1..`NN',1...]
drop r__* rz__* `l_varlist'

mata: st_matrix("cycle",m(`ncom'+`ncomio',`lags'))
matrix fred=cycle
matrix drop yy dym dy_ dy m_dy m
return clear
return matrix cycle = cycle

local time =c(current_time)
local qw = tc(`time')
local u=1

foreach var of local varlist {
matrix fred`var'=fred[1...,`u']
svmat fred`var', names(cycle_`var'_`qw')
local u=`u'+1
}

if `ncomio' != 0 {
local u=1
foreach var of local vario {
matrix fred`var'=fred[1...,`u'+`ncom']
svmat fred`var', names(cycle_`var'_`qw')
local u=`u'+1
}
}
}
end
