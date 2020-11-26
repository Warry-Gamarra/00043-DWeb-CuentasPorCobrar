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
    public class PeriodoModel
    {
        PeriodoService periodoService;

        public PeriodoModel()
        {
            periodoService = new PeriodoService();
        }

        public List<SelectViewModel> Listar_Combo_TipoPeriodo()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = periodoService.Listar_Tipo_Periodo_Habilitados();

            if (lista != null)
            {
                result = lista.Select(x => new SelectViewModel() {
                    Value = x.I_TipoPeriodoID.ToString(),
                    TextDisplay = x.T_TipoPerDesc
                }).ToList();
            }

            return result;
        }

        public int Obtener_Prioridad_Tipo_Periodo(int I_TipoPeriodoID)
        {
            return periodoService.Obtener_Prioridad_Tipo_Periodo(I_TipoPeriodoID);
        }

        public List<SelectViewModel> Listar_Combo_CtaDepositoHabilitadas(int I_TipoPeriodoID)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = periodoService.Listar_Cuenta_Deposito_Habilitadas(I_TipoPeriodoID);

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

        public List<PeriodoViewModel> Listar_Periodos_Habilitados()
        {
            List<PeriodoViewModel> result = new List<PeriodoViewModel>();

            var lista = periodoService.Listar_Periodos_Habilitados();

            if (lista != null)
            {
                result = lista.Select(x => new PeriodoViewModel()
                {
                    I_PeriodoID = x.I_PeriodoID,
                    T_TipoPerDesc = x.T_TipoPerDesc,
                    I_Anio = x.I_Anio,
                    D_FecVencto = x.D_FecVencto,
                    I_Prioridad = x.I_Prioridad
                }).ToList();
            }

            return result;
        }

        public Response Grabar_Periodo(MantenimientoPeriodoViewModel model, int currentUserId)
        {
            PeriodoEntity periodoEntity;
            CtaDepoPeriodoEntity ctaDepoPeriodoEntity;

            var periodoSaveOption = (!model.I_PeriodoID.HasValue) ? SaveOption.Insert : SaveOption.Update;

            periodoEntity = new PeriodoEntity()
            {
                I_PeriodoID = model.I_PeriodoID.GetValueOrDefault(),
                I_TipoPeriodoID = model.I_TipoPeriodoID,
                I_Anio = model.I_Anio,
                D_FecVencto = model.D_FecVencto,
                I_Prioridad = model.I_Prioridad,
                B_Habilitado = model.B_Habilitado.HasValue ? model.B_Habilitado.GetValueOrDefault() : true,
                I_UsuarioCre = currentUserId,
                I_UsuarioMod = currentUserId
            };

            var resultPeriodo = periodoService.Grabar_Periodo(periodoEntity, periodoSaveOption);

            if (resultPeriodo.Value)
            {
                periodoEntity.I_PeriodoID = int.Parse(resultPeriodo.CurrentID);

                var ctasDeposito = periodoService.Obtener_CtasDepoPeriodo(periodoEntity.I_PeriodoID);

                if (ctasDeposito != null && ctasDeposito.Count > 0)
                {
                    if (model.Arr_CtaDepositoID != null)
                    {
                        for (int i = 0; i < model.Arr_CtaDepositoID.Length; i++)
                        {
                            int ctaDepositoID = model.Arr_CtaDepositoID[i];

                            if (ctasDeposito.Exists(x => x.I_CtaDepositoID == ctaDepositoID))
                            {
                                ctaDepoPeriodoEntity = ctasDeposito.FirstOrDefault(x => x.I_CtaDepositoID == ctaDepositoID);

                                if (!ctaDepoPeriodoEntity.B_Habilitado)
                                {
                                    ctaDepoPeriodoEntity.B_Habilitado = true;
                                    ctaDepoPeriodoEntity.I_UsuarioMod = currentUserId;
                                    periodoService.Grabar_CtaDepoPeriodo(ctaDepoPeriodoEntity, SaveOption.Update);
                                }
                            }
                            else
                            {
                                ctaDepoPeriodoEntity = new CtaDepoPeriodoEntity()
                                {
                                    I_PeriodoID = periodoEntity.I_PeriodoID,
                                    I_CtaDepositoID = ctaDepositoID,
                                    I_UsuarioCre = currentUserId,
                                    B_Habilitado = true
                                };

                                periodoService.Grabar_CtaDepoPeriodo(ctaDepoPeriodoEntity, SaveOption.Insert);
                            }
                        }

                        var listaDeshabilitar = ctasDeposito.FindAll(x => !model.Arr_CtaDepositoID.Contains(x.I_CtaDepositoID));

                        foreach (var item in listaDeshabilitar)
                        {
                            if (item.B_Habilitado)
                            {
                                item.I_UsuarioMod = currentUserId;
                                item.B_Habilitado = false;

                                periodoService.Grabar_CtaDepoPeriodo(item, SaveOption.Update);
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
                                periodoService.Grabar_CtaDepoPeriodo(item, SaveOption.Update);
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
                            ctaDepoPeriodoEntity = new CtaDepoPeriodoEntity()
                            {
                                I_PeriodoID = periodoEntity.I_PeriodoID,
                                I_CtaDepositoID = item,
                                I_UsuarioCre = currentUserId,
                                B_Habilitado = true
                            };

                            periodoService.Grabar_CtaDepoPeriodo(ctaDepoPeriodoEntity, SaveOption.Insert);
                        }
                    }
                }
            }

            return resultPeriodo;
        }

        public MantenimientoPeriodoViewModel Obtener_Periodo(int I_PeriodoID)
        {
            var periodo = periodoService.Obtener_Periodo(I_PeriodoID);

            var model = new MantenimientoPeriodoViewModel()
            {
                I_PeriodoID = periodo.I_PeriodoID,
                I_TipoPeriodoID = periodo.I_TipoPeriodoID,
                I_Anio = periodo.I_Anio,
                D_FecVencto = periodo.D_FecVencto,
                I_Prioridad = periodo.I_Prioridad,
                B_Habilitado = periodo.B_Habilitado
            };

            return model;
        }

        public List<SelectViewModel> Listar_Combo_CtasDepoPeriodo(int I_PeriodoID)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = periodoService.Obtener_CtasDepo_X_Periodo(I_PeriodoID);

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

        public List<short> Listar_Anios()
        {
            var lista = new List<short>();

            for (int i = DateTime.Now.Year + 3; 1963 < i; i--)
            {
                lista.Add((short)i);
            }

            return lista;
        }
    }
}