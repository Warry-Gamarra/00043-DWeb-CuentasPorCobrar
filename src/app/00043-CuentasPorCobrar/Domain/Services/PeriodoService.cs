using Data.Procedures;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public class PeriodoService
    {
        public List<CuentaDeposito> ListarCuentaDeposito()
        {
            try
            {
                var lista = USP_S_CuentaDeposito.Execute();

                var periodos = lista.Select(x => new CuentaDeposito()
                {
                    I_CtaDepID = x.I_CtaDepID,
                    C_NumeroCuenta = x.C_NumeroCuenta,
                    T_EntidadDesc = x.T_EntidadDesc
                }).ToList();

                return periodos;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public List<Periodo> ListarPeriodos()
        {
            try
            {
                var lista = USP_S_Periodos.Execute();

                var periodos = lista.Select(x => new Periodo()
                {
                    I_PeriodoID = x.I_PeriodoID,
                    T_CuotaPagoDesc = x.T_CuotaPagoDesc,
                    N_Anio = x.N_Anio,
                    D_FecIni = x.D_FecIni,
                    D_FecFin = x.D_FecFin
                }).ToList();

                return periodos;
            }
            catch (Exception)
            {
                return null;
            }
        }
    }
}
