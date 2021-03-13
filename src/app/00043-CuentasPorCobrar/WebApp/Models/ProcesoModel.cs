using Domain.DTO;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class ProcesoModel
    {
        private readonly ProcesoService procesoService;
        private readonly ConceptoPagoService conceptoPagoService;
        private readonly IEntidadFinanciera _entidadFinanciera;
        private readonly ICuentaDeposito _cuentaDeposito;

        public ProcesoModel()
        {
            procesoService = new ProcesoService();
            conceptoPagoService = new ConceptoPagoService();
            _entidadFinanciera = new EntidadFinanciera();
            _cuentaDeposito = new CuentaDeposito();
        }

        public List<ConceptoPagoViewModel> ObtenerConceptosProcesoHabilitados(int procesoID)
        {
            var lista = conceptoPagoService.Listar_ConceptoPago_Habilitados(procesoID);

            var result = lista.Select(x => new ConceptoPagoViewModel()
            {
                ProcesoId = procesoID,
                DescProceso = string.IsNullOrEmpty(x.T_ProcesoDesc) ? $"{x.I_Anio}-{x.I_Periodo}-{x.T_CatPagoDesc}" : x.T_ProcesoDesc,
                ConceptoPagoID = x.I_ConcPagID,
                ConceptoDesc = x.T_ConceptoDesc,
                Monto = x.M_Monto,
                Habilitado = true
            }).ToList();

            return result;
        }

        public int Obtener_Prioridad_Tipo_Proceso(int I_CatPagoID)
        {
            return procesoService.Obtener_Prioridad_CategoriaPago(I_CatPagoID);
        }

        public List<SelectGroupViewModel> Listar_Combo_CtaDepositoHabilitadas(int I_CatPagoID)
        {
            List<SelectGroupViewModel> result = new List<SelectGroupViewModel>();

            var lista = procesoService.Listar_Cuenta_Deposito_Habilitadas(I_CatPagoID);

            if (lista != null)
            {
                foreach (var entidad in lista.Select(x => x.T_EntidadDesc).Distinct())
                {
                    result.Add(new SelectGroupViewModel()
                    {
                        NameGroup = entidad,
                        ItemsGroup = lista.Where(x => x.T_EntidadDesc == entidad).Select(x => new SelectViewModel()
                        {
                            Value = x.I_CtaDepID.ToString(),
                            TextDisplay = String.Format("{0} - {1}", x.T_DescCuenta, x.C_NumeroCuenta),
                            NameGroup = entidad
                        }).ToList()
                    });
                }
            }

            return result;
        }

        public List<ProcesoViewModel> Listar_Procesos(int anio)
        {
            List<ProcesoViewModel> result = new List<ProcesoViewModel>();

            var lista = procesoService.Listar_Procesos().Where(x => x.I_Anio == anio);

            if (lista != null)
            {
                result = lista.Select(x => new ProcesoViewModel()
                {
                    I_ProcesoID = x.I_ProcesoID,
                    T_CatPagoDesc = x.T_CatPagoDesc,
                    T_ProcesoDesc = string.IsNullOrEmpty(x.T_ProcesoDesc) ? $"{x.I_Anio.ToString()}-{x.C_PeriodoCod}-{x.T_CatPagoDesc}" : x.T_CatPagoDesc,
                    T_Periodo = x.T_PeriodoDesc,
                    I_Anio = x.I_Anio,
                    D_FecVencto = x.D_FecVencto,
                    I_Prioridad = x.I_Prioridad
                }).ToList();
            }

            return result;
        }


        public List<ProcesoViewModel> Listar_Tasas()
        {
            List<ProcesoViewModel> result = new List<ProcesoViewModel>();

            var lista = procesoService.Listar_Procesos();

            if (lista != null)
            {
                result = lista.Select(x => new ProcesoViewModel()
                {
                    I_ProcesoID = x.I_ProcesoID,
                    T_CatPagoDesc = x.T_CatPagoDesc,
                    I_Anio = x.I_Anio,
                    D_FecVencto = x.D_FecVencto,
                    I_Prioridad = x.I_Prioridad
                }).ToList();
            }

            return result;
        }

        public Response Grabar_Proceso(RegistroProcesoViewModel model, int currentUserId)
        {
            ProcesoEntity procesoEntity;
            CtaDepoProcesoEntity ctaDepoProcesoEntity;

            var procesoSaveOption = (!model.ProcesoId.HasValue) ? SaveOption.Insert : SaveOption.Update;

            procesoEntity = new ProcesoEntity()
            {
                I_ProcesoID = model.ProcesoId.GetValueOrDefault(),
                I_CatPagoID = model.CategoriaId.Value,
                I_Anio = model.Anio,
                I_Periodo = model.PerAcadId,
                D_FecVencto = model.FecVencto,
                I_Prioridad = model.PrioridadId,
                N_CodBanco = model.CodBcoComercio,
                B_Habilitado = true,
                I_UsuarioCre = currentUserId,
                I_UsuarioMod = currentUserId
            };

            var resultProceso = procesoService.Grabar_Proceso(procesoEntity, procesoSaveOption);

            if (resultProceso.Value)
            {
                procesoEntity.I_ProcesoID = int.Parse(resultProceso.CurrentID);

                var ctasDeposito = procesoService.Obtener_CtasDepoProceso(procesoEntity.I_ProcesoID);

                if (ctasDeposito != null && ctasDeposito.Count > 0)
                {
                    if (model.CtaDepositoID != null)
                    {
                        for (int i = 0; i < model.CtaDepositoID.Length; i++)
                        {
                            int ctaDepositoID = model.CtaDepositoID[i];

                            if (ctasDeposito.Exists(x => x.I_CtaDepositoID == ctaDepositoID))
                            {
                                ctaDepoProcesoEntity = ctasDeposito.FirstOrDefault(x => x.I_CtaDepositoID == ctaDepositoID);

                                if (!ctaDepoProcesoEntity.B_Habilitado)
                                {
                                    ctaDepoProcesoEntity.B_Habilitado = true;
                                    ctaDepoProcesoEntity.I_UsuarioMod = currentUserId;
                                    procesoService.Grabar_CtaDepoProceso(ctaDepoProcesoEntity, SaveOption.Update);
                                }
                            }
                            else
                            {
                                ctaDepoProcesoEntity = new CtaDepoProcesoEntity()
                                {
                                    I_ProcesoID = procesoEntity.I_ProcesoID,
                                    I_CtaDepositoID = ctaDepositoID,
                                    I_UsuarioCre = currentUserId,
                                    B_Habilitado = true
                                };

                                procesoService.Grabar_CtaDepoProceso(ctaDepoProcesoEntity, SaveOption.Insert);
                            }
                        }

                        var listaDeshabilitar = ctasDeposito.FindAll(x => !model.CtaDepositoID.Contains(x.I_CtaDepositoID));

                        foreach (var item in listaDeshabilitar)
                        {
                            if (item.B_Habilitado)
                            {
                                item.I_UsuarioMod = currentUserId;
                                item.B_Habilitado = false;

                                procesoService.Grabar_CtaDepoProceso(item, SaveOption.Update);
                            }
                        }
                    }
                    else
                    {
                        foreach (var item in ctasDeposito)
                        {
                            if (item.B_Habilitado)
                            {
                                item.I_UsuarioMod = currentUserId;
                                item.B_Habilitado = false;
                                procesoService.Grabar_CtaDepoProceso(item, SaveOption.Update);
                            }
                        }
                    }
                }
                else
                {
                    if (model.CtaDepositoID != null)
                    {
                        foreach (var item in model.CtaDepositoID)
                        {
                            ctaDepoProcesoEntity = new CtaDepoProcesoEntity()
                            {
                                I_ProcesoID = procesoEntity.I_ProcesoID,
                                I_CtaDepositoID = item,
                                I_UsuarioCre = currentUserId,
                                B_Habilitado = true
                            };

                            procesoService.Grabar_CtaDepoProceso(ctaDepoProcesoEntity, SaveOption.Insert);
                        }
                    }
                }
            }

            if (resultProceso.Value)
            {
                resultProceso.Success(false);
            }
            else
            {
                resultProceso.Error(true);
            }

            return resultProceso;
        }


        public RegistroProcesoViewModel Obtener_Proceso(int I_ProcesoID)
        {
            var proceso = procesoService.Obtener_Proceso(I_ProcesoID);
            var ctasBcoComercio = _cuentaDeposito.Find().Where(x => x.I_EntidadFinanId == Constantes.BANCO_COMERCIO_ID);

            var cuentasProceso = procesoService.Obtener_CtasDepo_X_Proceso(I_ProcesoID);

            var model = new RegistroProcesoViewModel()
            {
                ProcesoId = proceso.I_ProcesoID,
                CategoriaId = proceso.I_CatPagoID,
                Anio = proceso.I_Anio.Value,
                PerAcadId = proceso.I_Periodo,
                DescProceso = string.IsNullOrEmpty(proceso.T_ProcesoDesc) ? $"{proceso.I_Anio.ToString()}-{proceso.C_PeriodoCod}-{proceso.T_CatPagoDesc}" : proceso.T_ProcesoDesc,
                FecVencto = proceso.D_FecVencto,
                PrioridadId = proceso.I_Prioridad,
                CtasBcoComercio = ctasBcoComercio.Select(x => x.I_CtaDepID).ToArray(),
                CodBcoComercio = proceso.N_CodBanco,
                CtaDepositoID = cuentasProceso.Select(x => x.I_CtaDepositoID).ToArray()                
            };

            if (cuentasProceso.Where(x => x.I_EntidadFinanID == Constantes.BANCO_COMERCIO_ID).Count() > 0)
                model.MostrarCodBanco = true;

            return model;
        }

        public List<SelectViewModel> Listar_Anios()
        {
            var lista = new List<SelectViewModel>();

            for (int i = DateTime.Now.Year + 3; 1963 < i; i--)
            {
                lista.Add(new SelectViewModel() { Value = i.ToString(), TextDisplay = i.ToString() });
            }

            return lista;
        }
    }
}