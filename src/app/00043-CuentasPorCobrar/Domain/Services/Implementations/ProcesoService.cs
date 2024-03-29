﻿using Data;
using Data.Procedures;
using Data.Tables;
using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Views;

namespace Domain.Services.Implementations
{
    public class ProcesoService : IProcesoService
    {
        public List<CategoriaPago> Listar_CategoriaPago_Habilitados()
        {
            try
            {
                var lista = TC_CategoriaPago.FindAll();

                var result = lista.Where(x => x.B_Habilitado && !x.B_Eliminado).Select(x => new CategoriaPago()
                {
                    CategoriaId = x.I_CatPagoID,
                    Descripcion = x.T_CatPagoDesc,
                    Prioridad = x.I_Prioridad,
                    Nivel = x.I_Nivel,
                    TipoAlumno = x.I_TipoAlumno
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
                    T_DescCuenta = x.T_DescCuenta,
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

                var result = lista.Select(x => Mapper.USP_S_Procesos_To_Proceso(x)).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public Response Grabar_Proceso(ProcesoEntity procesoEntity, SaveOption saveOption)
        {
            ResponseData result;
            List<USP_S_Procesos> listaProcesos;

            switch (saveOption)
            {
                case SaveOption.Insert:

                    listaProcesos = USP_S_Procesos.Execute();

                    if (listaProcesos.FirstOrDefault(x => x.I_CatPagoID == procesoEntity.I_CatPagoID 
                                                                   && x.I_Anio == procesoEntity.I_Anio 
                                                                   && x.I_Periodo == procesoEntity.I_Periodo) != null)
                    {
                        return new Response() { Value =false, Message = "La cuota de pago ya se encuentra registrada" };
                    }

                    if (procesoEntity.cuotaPagoID.HasValue && listaProcesos.Exists(x => x.I_CuotaPagoID.HasValue && x.I_CuotaPagoID.Value.Equals(procesoEntity.cuotaPagoID.Value)))
                    {
                        return new Response() { Value = false, Message = "El ID de Cuota de Pago se repite en este sistema." };
                    }

                    var grabarProceso = new USP_I_GrabarProceso()
                    {
                        I_CatPagoID = procesoEntity.I_CatPagoID,
                        I_Anio = procesoEntity.I_Anio,
                        D_FecVencto = procesoEntity.D_FecVencto,
                        D_FecVenctoExt = procesoEntity.D_FecVenctoExt,
                        I_Prioridad = procesoEntity.I_Prioridad ?? Obtener_Prioridad_CategoriaPago(procesoEntity.I_CatPagoID),
                        I_Periodo = procesoEntity.I_Periodo,
                        N_CodBanco = procesoEntity.N_CodBanco,
                        T_ProcesoDesc = procesoEntity.T_ProcesoDesc,
                        I_UsuarioCre = procesoEntity.I_UsuarioCre.GetValueOrDefault(),
                        I_CuotaPagoID = procesoEntity.cuotaPagoID
                    };

                    result = grabarProceso.Execute();

                    break;

                case SaveOption.Update:
                    
                    listaProcesos = USP_S_Procesos.Execute();

                    if (procesoEntity.cuotaPagoID.HasValue && listaProcesos.Exists(x =>
                        x.I_ProcesoID != procesoEntity.I_ProcesoID && x.I_CuotaPagoID.HasValue && x.I_CuotaPagoID.Value.Equals(procesoEntity.cuotaPagoID.Value)))
                    {
                        return new Response() { Value = false, Message = "El ID de Cuota de Pago se repite en este sistema." };
                    }

                    var actualizarProceso = new USP_U_ActualizarProceso()
                    {
                        I_ProcesoID = procesoEntity.I_ProcesoID,
                        I_CatPagoID = procesoEntity.I_CatPagoID,
                        I_Anio = procesoEntity.I_Anio,
                        D_FecVencto = procesoEntity.D_FecVencto,
                        D_FecVenctoExt = procesoEntity.D_FecVenctoExt,
                        I_Prioridad = procesoEntity.I_Prioridad,
                        B_Habilitado = procesoEntity.B_Habilitado,
                        T_ProcesoDesc = procesoEntity.T_ProcesoDesc,
                        N_CodBanco = procesoEntity.N_CodBanco,
                        I_UsuarioMod = procesoEntity.I_UsuarioMod.GetValueOrDefault(),
                        editarFecha = procesoEntity.editarFecha,
                        I_CuotaPagoID = procesoEntity.cuotaPagoID
                    };

                    result = actualizarProceso.Execute();

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

        public Response Grabar_CtaDepoProceso(CtaDepoProcesoEntity ctaDepoProcesoEntity, SaveOption saveOption)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    var grabarCtaDepoProceso = new USP_I_GrabarCtaDeposito_Proceso()
                    {
                        I_CtaDepositoID = ctaDepoProcesoEntity.I_CtaDepositoID,
                        I_ProcesoID = ctaDepoProcesoEntity.I_ProcesoID,
                        I_UsuarioCre = ctaDepoProcesoEntity.I_UsuarioCre.GetValueOrDefault()
                    };

                    result = grabarCtaDepoProceso.Execute();

                    break;

                case SaveOption.Update:
                    var actualizarCtaDepoProceso = new USP_U_ActualizarCtaDeposito_Proceso()
                    {
                        I_CtaDepoProID = ctaDepoProcesoEntity.I_CtaDepoProID,
                        I_CtaDepositoID = ctaDepoProcesoEntity.I_CtaDepositoID,
                        I_ProcesoID = ctaDepoProcesoEntity.I_ProcesoID,
                        B_Habilitado = ctaDepoProcesoEntity.B_Habilitado,
                        I_UsuarioMod = ctaDepoProcesoEntity.I_UsuarioMod.GetValueOrDefault()
                    };

                    result = actualizarCtaDepoProceso.Execute();

                    break;

                default:
                    throw new NotSupportedException("Acción no válida.");
            }

            return new Response(result);
        }

        public Proceso Obtener_Proceso(int I_ProcesoID)
        {
            Proceso result = null;

            try
            {
                var proceso = USP_S_Procesos.Execute().Find(x => x.I_ProcesoID == I_ProcesoID);

                if (proceso != null)
                {
                    result = Mapper.USP_S_Procesos_To_Proceso(proceso);
                }
            }
            catch (Exception ex)
            {
                return result;
            }

            return result;
        }

        public List<CtaDepoProcesoEntity> Obtener_CtasDepoProceso(int I_ProcesoID)
        {
            try
            {
                var lista = TI_CtaDepo_Proceso.FindByProceso(I_ProcesoID);

                var result = lista.Select(x => new CtaDepoProcesoEntity()
                {
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

        public List<CtaDepoProceso> Obtener_CtasDepo_X_Proceso(int I_ProcesoID)
        {
            try
            {
                var lista = VW_CtaDepositoProceso.GetCtaDepositoByProceso(I_ProcesoID);

                var result = lista.Where(x => x.B_Habilitado)
                    .Select(x => Mapper.VW_CtaDepositoProceso_To_CtaDepoProceso(x)).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public IEnumerable<DateTime> Listar_FechaVencimientoObligacion(int I_ProcesoID)
        {
            return USP_S_ObtenerFechaVencimientoObligacion.Execute(I_ProcesoID);
        }

        public Response Actualizar_FechaVctoObligacion(DateTime newFechaVcto, DateTime oldFechaVcto, int idProceso, int currentUserId)
        {
            ResponseData result;

            var sp = new USP_U_ActualizarFechaVencimientoObligaciones()
            {
                D_NewFecVencto = newFechaVcto,
                D_OldFecVencto = oldFechaVcto,
                I_ProcesoID = idProceso,
                I_UsuarioMod = currentUserId
            };

            result = sp.Execute();

            return new Response(result);
        }
    }
}
