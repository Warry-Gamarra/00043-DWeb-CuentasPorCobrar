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
    public class ProcesoService
    {
        public List<CategoriaPago> Listar_CategoriaPago_Habilitados()
        {
            try
            {
                var lista = TC_CategoriaPago.FindAll();

                var result = lista.Where(x => x.B_Habilitado && !x.B_Eliminado).Select(x => new CategoriaPago()
                {
                    I_CatPagoID = x.I_CatPagoID,
                    T_CatPagoDesc = x.T_CatPagoDesc,
                    I_Prioridad = x.I_Prioridad
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public int Obtener_Prioridad_CategoriaPago(int I_CatPagoID)
        {
            try
            {
                var result = TC_CategoriaPago.FindByID(I_CatPagoID);

                return result.I_Prioridad;
            }
            catch (Exception ex)
            {
                return 0;
            }
        }

        public List<CuentaDeposito> Listar_Cuenta_Deposito_Habilitadas(int I_CatPagoID)
        {
            try
            {
                var lista = USP_S_CuentaDeposito_Habilitadas.Execute(I_CatPagoID);

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

        public List<Proceso> Listar_Procesos()
        {
            try
            {
                var lista = USP_S_Procesos.Execute();

                var result = lista.Select(x => new Proceso()
                {
                    I_ProcesoID = x.I_ProcesoID,
                    T_CatPagoDesc = x.T_CatPagoDesc,
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

        public Response Grabar_Proceso(ProcesoEntity proceso, SaveOption saveOption)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    var grabarPeriodo = new USP_I_GrabarProceso()
                    {
                        I_CatPagoID = proceso.I_CatPagoID,
                        I_Anio = proceso.I_Anio,
                        D_FecVencto = proceso.D_FecVencto,
                        I_Prioridad = proceso.I_Prioridad,
                        I_UsuarioCre = proceso.I_UsuarioCre.GetValueOrDefault()
                    };

                    result = grabarPeriodo.Execute();

                    break;

                case SaveOption.Update:
                    var actualizarPeriodo = new USP_U_ActualizarProceso()
                    {
                        I_ProcesoID = proceso.I_ProcesoID,
                        I_CatPagoID = proceso.I_CatPagoID,
                        I_Anio = proceso.I_Anio,
                        D_FecVencto = proceso.D_FecVencto,
                        I_Prioridad = proceso.I_Prioridad,
                        B_Habilitado = proceso.B_Habilitado,
                        I_UsuarioMod = proceso.I_UsuarioMod.GetValueOrDefault()
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

        public Response Grabar_CtaDepoProceso(CtaDepoProcesoEntity proceso, SaveOption saveOption)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    var grabarCtaDepoPeriodo = new USP_I_GrabarCtaDeposito_Proceso()
                    {
                        I_CtaDepositoID = proceso.I_CtaDepositoID,
                        I_ProcesoID = proceso.I_ProcesoID,
                        I_UsuarioCre = proceso.I_UsuarioCre.GetValueOrDefault()
                    };

                    result = grabarCtaDepoPeriodo.Execute();

                    break;

                case SaveOption.Update:
                    var actualizarCtaDepoPeriodo = new USP_U_ActualizarCtaDeposito_Proceso()
                    {
                        I_CtaDepoProID = proceso.I_CtaDepoProID,
                        I_CtaDepositoID = proceso.I_CtaDepositoID,
                        I_ProcesoID = proceso.I_ProcesoID,
                        B_Habilitado = proceso.B_Habilitado,
                        I_UsuarioMod = proceso.I_UsuarioMod.GetValueOrDefault()
                    };

                    result = actualizarCtaDepoPeriodo.Execute();

                    break;

                default:
                    throw new NotSupportedException("Acción no válida.");
            }

            return new Response(result);
        }

        public ProcesoEntity Obtener_Proceso(int I_ProcesoID)
        {
            ProcesoEntity result = null;

            try
            {
                var periodo = TC_Proceso.FindByID(I_ProcesoID);

                if (periodo != null)
                {
                    result = new ProcesoEntity()
                    {
                        I_ProcesoID = periodo.I_ProcesoID,
                        I_CatPagoID = periodo.I_CatPagoID,
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

        public List<CtaDepoProcesoEntity> Obtener_CtasDepoProceso(int I_PeriodoID)
        {
            try
            {
                var lista = TI_CtaDepo_Proceso.FindByPeriodo(I_PeriodoID);

                var result = lista.Select(x => new CtaDepoProcesoEntity() {
                    I_CtaDepoProID = x.I_CtaDepoProID,
                    I_CtaDepositoID = x.I_CtaDepositoID,
                    I_ProcesoID = x.I_ProcesoID,
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

        public List<CtaDepoProceso> Obtener_CtasDepo_X_Periodo(int I_ProcesoID)
        {
            try
            {
                var lista = USP_S_CtaDepo_Proceso.Execute(I_ProcesoID);

                var result = lista.Select(x => new CtaDepoProceso()
                {
                    I_CtaDepoProID = x.I_CtaDepoProID,
                    I_CtaDepositoID = x.I_CtaDepositoID,
                    I_ProcesoID = x.I_ProcesoID,
                    B_Habilitado = x.B_Habilitado,
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
    }
}
