using Data;
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
        public List<TipoPeriodo> Listar_Tipo_Periodo_Habilitados()
        {
            try
            {
                var lista = TC_TipoPeriodo.FindAll();

                var result = lista.Where(x => x.B_Habilitado && !x.B_Eliminado).Select(x => new TipoPeriodo()
                {
                    I_TipoPeriodoID = x.I_TipoPeriodoID,
                    T_TipoPerDesc = x.T_TipoPerDesc,
                    I_Prioridad = x.I_Prioridad
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public int Obtener_Prioridad_Tipo_Periodo(int I_TipoPeriodoID)
        {
            try
            {
                var result = TC_TipoPeriodo.FindByID(I_TipoPeriodoID);

                return result.I_Prioridad;
            }
            catch (Exception ex)
            {
                return 0;
            }
        }

        public List<CuentaDeposito> Listar_Cuenta_Deposito_Habilitadas(int I_TipoPeriodoID)
        {
            try
            {
                var lista = USP_S_CuentaDeposito_Habilitadas.Execute(I_TipoPeriodoID);

                var result = lista.Select(x => new CuentaDeposito()
                {
                    I_CtaDepID = x.I_CtaDepositoID,
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
                    T_TipoPerDesc = x.T_TipoPerDesc,
                    I_Anio = x.I_Anio,
                    D_FecVencto = x.D_FecVencto,
                    I_Prioridad = x.I_Prioridad
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public Response Grabar_Periodo(PeriodoEntity periodo, SaveOption saveOption)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    var grabarPeriodo = new USP_I_GrabarPeriodo()
                    {
                        I_TipoPeriodoID = periodo.I_TipoPeriodoID,
                        I_Anio = periodo.I_Anio,
                        D_FecVencto = periodo.D_FecVencto,
                        I_Prioridad = periodo.I_Prioridad,
                        I_UsuarioCre = periodo.I_UsuarioCre.GetValueOrDefault()
                    };

                    result = grabarPeriodo.Execute();

                    break;

                case SaveOption.Update:
                    var actualizarPeriodo = new USP_U_ActualizarPeriodo()
                    {
                        I_PeriodoID = periodo.I_PeriodoID,
                        I_TipoPeriodoID = periodo.I_TipoPeriodoID,
                        I_Anio = periodo.I_Anio,
                        D_FecVencto = periodo.D_FecVencto,
                        I_Prioridad = periodo.I_Prioridad,
                        B_Habilitado = periodo.B_Habilitado,
                        I_UsuarioMod = periodo.I_UsuarioMod.GetValueOrDefault()
                    };

                    result = actualizarPeriodo.Execute();

                    break;

                default:
                    result = new ResponseData()
                    {
                        Value = false,
                        Message = "Acción no válida."
                    };

                    break;
            }
            
            return new Response(result);
        }

        public Response Grabar_CtaDepoPeriodo(CtaDepoPeriodoEntity periodo, SaveOption saveOption)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    var grabarCtaDepoPeriodo = new USP_I_GrabarPeriodo_CuentaDeposito()
                    {
                        I_CtaDepositoID = periodo.I_CtaDepositoID,
                        I_PeriodoID = periodo.I_PeriodoID,
                        I_UsuarioCre = periodo.I_UsuarioCre.GetValueOrDefault()
                    };

                    result = grabarCtaDepoPeriodo.Execute();

                    break;

                case SaveOption.Update:
                    var actualizarCtaDepoPeriodo = new USP_U_ActualizarPeriodo_CuentaDeposito()
                    {
                        I_CtaDepoPerID = periodo.I_CtaDepoPerID,
                        I_CtaDepositoID = periodo.I_CtaDepositoID,
                        I_PeriodoID = periodo.I_PeriodoID,
                        B_Habilitado = periodo.B_Habilitado,
                        I_UsuarioMod = periodo.I_UsuarioMod.GetValueOrDefault()
                    };

                    result = actualizarCtaDepoPeriodo.Execute();

                    break;

                default:
                    throw new NotSupportedException("Acción no válida.");
            }

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
                        I_TipoPeriodoID = periodo.I_TipoPeriodoID,
                        I_Anio = periodo.I_Anio,
                        D_FecVencto = periodo.D_FecVencto,
                        I_Prioridad = periodo.I_Prioridad,
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

        public List<CtaDepoPeriodoEntity> Obtener_CtasDepoPeriodo(int I_PeriodoID)
        {
            try
            {
                var lista = TI_CtaDepo_Periodo.FindByPeriodo(I_PeriodoID);

                var result = lista.Select(x => new CtaDepoPeriodoEntity() {
                    I_CtaDepoPerID = x.I_CtaDepoPerID,
                    I_CtaDepositoID = x.I_CtaDepositoID,
                    I_PeriodoID = x.I_PeriodoID,
                    B_Habilitado = x.B_Habilitado,
                    I_UsuarioCre = x.I_UsuarioCre,
                    I_UsuarioMod = x.I_UsuarioMod
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
