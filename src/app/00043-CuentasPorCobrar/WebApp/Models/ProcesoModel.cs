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

        public ProcesoModel()
        {
            procesoService = new ProcesoService();
            conceptoPagoService = new ConceptoPagoService();
        }

        public RegistroConceptosProcesoViewModel ObtenerConceptosProceso(int procesoID)
        {
            CategoriaPagoModel categoriaModel = new CategoriaPagoModel();
            var proceso = procesoService.Obtener_Proceso(procesoID);
            var conceptosPago = new List<ConceptoPagoViewModel>();

            RegistroConceptosProcesoViewModel result = new RegistroConceptosProcesoViewModel()
            {
                CategoriaId = proceso.I_CatPagoID,
                DescProceso = $"{proceso.I_Anio}-{proceso.I_Periodo}-{proceso.T_CatPagoDesc}",
                AnioProceso = proceso.I_Anio,
                FecVencto = proceso.D_FecVencto,
                ProcesoId = proceso.I_ProcesoID,
                Conceptos = conceptosPago
            };

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
                    T_CatPagoDesc = $"{x.I_Anio.ToString()}-{x.C_PeriodoCod}-{x.T_CatPagoDesc}",
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

            var model = new RegistroProcesoViewModel()
            {
                ProcesoId = proceso.I_ProcesoID,
                CategoriaId = proceso.I_CatPagoID,
                Anio = proceso.I_Anio.Value,
                PerAcadId = proceso.I_Periodo,
                FecVencto = proceso.D_FecVencto,
                PrioridadId = proceso.I_Prioridad,
                CtaDepositoID = procesoService.Obtener_CtasDepo_X_Proceso(I_ProcesoID).Select(x => x.I_CtaDepositoID).ToArray()
            };

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