using Data.Procedures;
using Data.Tables;
using Domain.DTO;
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
        public List<CuotaPago> ListarCuotaPagoHabilitadas()
        {
            try
            {
                var lista = TC_CuotaPago.Find();

                var cuotasPago = lista.Where(x => x.B_Habilitado).Select(x => new CuotaPago()
                {
                    I_CuotaPagoID = x.I_CuotaPagoID,
                    T_CuotaPagoDesc = x.T_CuotaPagoDesc,
                    B_Habilitado = x.B_Habilitado
                }).ToList();

                return cuotasPago;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

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
            catch (Exception ex)
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
            catch (Exception ex)
            {
                return null;
            }
        }

        public Response GrabarPeriodo(Periodo periodo)
        {
            var sp = new USP_I_GrabarPeriodo()
            {
                I_CuotaPagoID = periodo.Cuota_Pago_ID,
                N_Anio = periodo.N_Anio,
                D_FecIni = periodo.D_FecIni,
                D_FecFin = periodo.D_FecFin
            };

            var result = sp.Execute();

            return new Response(result);
        }
    }
}
