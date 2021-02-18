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
        ProcesoService procesoService;

        public ProcesoModel()
        {
            procesoService = new ProcesoService();
        }

        public List<SelectViewModel> Listar_Combo_CategoriaPago()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = procesoService.Listar_CategoriaPago_Habilitados();

            if (lista != null)
            {
                result = lista.Select(x => new SelectViewModel() {
                    Value = x.CategoriaId.ToString(),
                    TextDisplay = x.Descripcion
                }).ToList();
            }

            return result;
        }

        public int Obtener_Prioridad_Tipo_Proceso(int I_CatPagoID)
        {
            return procesoService.Obtener_Prioridad_CategoriaPago(I_CatPagoID);
        }

        public List<SelectViewModel> Listar_Combo_CtaDepositoHabilitadas(int I_CatPagoID)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = procesoService.Listar_Cuenta_Deposito_Habilitadas(I_CatPagoID);

            if (lista != null)
            {
                result = lista.Select(x => new SelectViewModel()
                {
                    Value = x.I_CtaDepID.ToString(),
                    TextDisplay = String.Format("{0}: {1}", x.T_EntidadDesc, x.C_NumeroCuenta),
                }).ToList();
            }

            return result;
        }

        public List<ProcesoViewModel> Listar_Procesos()
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

        public Response Grabar_Proceso(MantenimientoProcesoViewModel model, int currentUserId)
        {
            ProcesoEntity procesoEntity;
            CtaDepoProcesoEntity ctaDepoProcesoEntity;

            var procesoSaveOption = (!model.I_ProcesoID.HasValue) ? SaveOption.Insert : SaveOption.Update;

            procesoEntity = new ProcesoEntity()
            {
                I_ProcesoID = model.I_ProcesoID.GetValueOrDefault(),
                I_CatPagoID = model.I_CatPagoID,
                I_Anio = model.I_Anio,
                D_FecVencto = model.D_FecVencto,
                I_Prioridad = model.I_Prioridad,
                B_Habilitado = model.B_Habilitado.HasValue ? model.B_Habilitado.GetValueOrDefault() : true,
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
                    if (model.Arr_CtaDepositoID != null)
                    {
                        for (int i = 0; i < model.Arr_CtaDepositoID.Length; i++)
                        {
                            int ctaDepositoID = model.Arr_CtaDepositoID[i];

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

                        var listaDeshabilitar = ctasDeposito.FindAll(x => !model.Arr_CtaDepositoID.Contains(x.I_CtaDepositoID));

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
                    if (model.Arr_CtaDepositoID != null)
                    {
                        foreach (var item in model.Arr_CtaDepositoID)
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

            return resultProceso;
        }

        public MantenimientoProcesoViewModel Obtener_Proceso(int I_ProcesoID)
        {
            var proceso = procesoService.Obtener_Proceso(I_ProcesoID);

            var model = new MantenimientoProcesoViewModel()
            {
                I_ProcesoID = proceso.I_ProcesoID,
                I_CatPagoID = proceso.I_CatPagoID,
                I_Anio = proceso.I_Anio,
                D_FecVencto = proceso.D_FecVencto,
                I_Prioridad = proceso.I_Prioridad,
                B_Habilitado = proceso.B_Habilitado
            };

            return model;
        }

        public List<SelectViewModel> Listar_Combo_CtasDepoProceso(int I_ProcesoID)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = procesoService.Obtener_CtasDepo_X_Proceso(I_ProcesoID);

            if (lista != null)
            {
                result = lista.Where(x => x.B_Habilitado).Select(x => new SelectViewModel()
                {
                    Value = x.I_CtaDepositoID.ToString(),
                    TextDisplay = String.Format("{0}: {1}", x.T_EntidadDesc, x.C_NumeroCuenta),
                }).ToList();
            }

            return result;
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