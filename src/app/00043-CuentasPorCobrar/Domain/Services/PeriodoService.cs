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
        public List<CuotaPago> Listar_Cuota_Pago_Habilitadas()
        {
            try
            {
                var lista = TC_CuotaPago.FindAll();

                var result = lista.Where(x => x.B_Habilitado).Select(x => new CuotaPago()
                {
                    I_CuotaPagoID = x.I_CuotaPagoID,
                    T_CuotaPagoDesc = x.T_CuotaPagoDesc,
                    B_Habilitado = x.B_Habilitado
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public List<CuentaDeposito> Listar_Cuenta_Deposito_Habilitadas()
        {
            try
            {
                var lista = USP_S_CuentaDeposito_Habilitadas.Execute();

                var result = lista.Select(x => new CuentaDeposito()
                {
                    I_CtaDepID = x.I_CtaDepID,
                    C_NumeroCuenta = x.C_NumeroCuenta,
                    T_EntidadDesc = x.T_EntidadDesc
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public List<Periodo> Listar_Periodos_Habilitados()
        {
            try
            {
                var lista = USP_S_Periodos_Habilitados.Execute();

                var result = lista.Select(x => new Periodo()
                {
                    I_PeriodoID = x.I_PeriodoID,
                    T_CuotaPagoDesc = x.T_CuotaPagoDesc,
                    N_Anio = x.N_Anio,
                    D_FecIni = x.D_FecIni,
                    D_FecFin = x.D_FecFin
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public Response Grabar_Periodo(PeriodoEntity periodo)
        {
            var sp = new USP_I_GrabarPeriodo()
            {
                I_CuotaPagoID = periodo.I_CuotaPagoID,
                N_Anio = periodo.N_Anio,
                D_FecIni = periodo.D_FecIni,
                D_FecFin = periodo.D_FecFin
            };

            var result = sp.Execute();

            return new Response(result);
        }

        public Response Actualizar_Periodo(PeriodoEntity periodo)
        {
            var sp = new USP_U_ActualizarPeriodo()
            {
                I_PeriodoID = periodo.I_PeriodoID,
                I_CuotaPagoID = periodo.I_CuotaPagoID,
                N_Anio = periodo.N_Anio,
                D_FecIni = periodo.D_FecIni,
                D_FecFin = periodo.D_FecFin,
                B_Habilitado = periodo.B_Habilitado
            };

            var result = sp.Execute();

            return new Response(result);
        }

        public PeriodoEntity Obtener_Periodo(int I_PeriodoID)
        {
            PeriodoEntity result = null;

            try
            {
                var periodo = TC_Periodo.FindByID(I_PeriodoID);

                if (periodo != null)
                {
                    result = new PeriodoEntity()
                    {
                        I_PeriodoID = periodo.I_PeriodoID,
                        I_CuotaPagoID = periodo.I_CuotaPagoID.GetValueOrDefault(),
                        N_Anio = periodo.N_Anio.GetValueOrDefault(),
                        D_FecIni = periodo.D_FecIni.GetValueOrDefault(),
                        D_FecFin = periodo.D_FecFin.GetValueOrDefault(),
                        B_Habilitado = periodo.B_Habilitado
                    };
                }
            }
            catch (Exception ex)
            {
                return result;
            }

            return result;
        }

        public List<Periodo_CuentaDeposito> Obtener_CuentaDeposito_X_Periodo(int I_PeriodoID)
        {
            try
            {
                var lista = TI_Periodo_CuentaDeposito.FindByPeriodoID(I_PeriodoID);

                var result = lista.Select(x => new Periodo_CuentaDeposito()
                {
                    I_PeriodoID = x.I_PeriodoID,
                    I_CtaDepID = x.I_CtaDepID
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
    }
}
