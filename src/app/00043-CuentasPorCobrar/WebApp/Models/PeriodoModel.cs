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

        public List<TipoPeriodo> Listar_Tipo_Periodo_Habilitados()
        {
            return periodoService.Listar_Tipo_Periodo_Habilitados();
        }

        public int Obtener_Prioridad_Tipo_Periodo(int I_TipoPeriodoID)
        {
            return periodoService.Obtener_Prioridad_Tipo_Periodo(I_TipoPeriodoID);
        }

        public List<CuentaDepositoApiModel> Listar_Cuenta_Deposito_Habilitadas(int I_TipoPeriodoID)
        {
            List<CuentaDepositoApiModel> result = new List<CuentaDepositoApiModel>();

            var lista = periodoService.Listar_Cuenta_Deposito_Habilitadas(I_TipoPeriodoID);

            if (lista != null)
            {
                result = lista.Select(x => new CuentaDepositoApiModel()
                {
                    I_CtaDepositoID = x.I_CtaDepID,
                    NumeroCuenta = x.C_NumeroCuenta,
                    EntidadFinanciera = x.T_EntidadDesc
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

                var ctaDeposito = periodoService.Obtener_CtasDepoPeriodo(periodoEntity.I_PeriodoID).FirstOrDefault();

                var ctaDepoPeriodoSaveOption = (ctaDeposito == null) ? SaveOption.Insert : SaveOption.Update;

                if (model.I_CtaDepositoID > 0)
                {
                    ctaDepoPeriodoEntity = new CtaDepoPeriodoEntity()
                    {
                        I_CtaDepoPerID = (ctaDeposito == null) ? 0 : ctaDeposito.I_CtaDepoPerID,
                        I_PeriodoID = periodoEntity.I_PeriodoID,
                        I_CtaDepositoID = model.I_CtaDepositoID,
                        I_UsuarioCre = currentUserId,
                        I_UsuarioMod = currentUserId,
                        B_Habilitado = true
                    };

                    var resultCtaDeposito = periodoService.Grabar_CtaDepoPeriodo(ctaDepoPeriodoEntity, ctaDepoPeriodoSaveOption);

                    return resultCtaDeposito;
                }
                else
                {
                    if (ctaDeposito != null)
                    {
                        ctaDepoPeriodoEntity = new CtaDepoPeriodoEntity()
                        {
                            I_CtaDepoPerID = ctaDeposito.I_CtaDepoPerID,
                            I_PeriodoID = ctaDeposito.I_PeriodoID,
                            I_CtaDepositoID = ctaDeposito.I_CtaDepositoID,
                            I_UsuarioMod = currentUserId,
                            B_Habilitado = false
                        };

                        var resultCtaDeposito = periodoService.Grabar_CtaDepoPeriodo(ctaDepoPeriodoEntity, ctaDepoPeriodoSaveOption);

                        return resultCtaDeposito;
                    }
                }
            }

            return resultPeriodo;
        }

        public MantenimientoPeriodoViewModel Obtener_Periodo(int I_PeriodoID)
        {
            var periodo = periodoService.Obtener_Periodo(I_PeriodoID);

            var listaCtaDeposito = periodoService.Obtener_CtasDepoPeriodo(periodo.I_PeriodoID);

            var ctaDeposito = listaCtaDeposito.Where(x => x.B_Habilitado).FirstOrDefault();

            var model = new MantenimientoPeriodoViewModel()
            {
                I_PeriodoID = periodo.I_PeriodoID,
                I_TipoPeriodoID = periodo.I_TipoPeriodoID,
                I_Anio = periodo.I_Anio,
                D_FecVencto = periodo.D_FecVencto,
                I_Prioridad = periodo.I_Prioridad,
                B_Habilitado = periodo.B_Habilitado,
                I_CtaDepositoID = (ctaDeposito == null) ? 0 : ctaDeposito.I_CtaDepositoID
            };

            return model;
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