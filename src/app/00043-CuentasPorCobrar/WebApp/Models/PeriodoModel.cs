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

        public List<CuotaPago> Listar_Cuota_Pago_Habilitadas()
        {
            return periodoService.Listar_Cuota_Pago_Habilitadas();
        }

        public List<CuentaDeposito> Listar_Cuenta_Deposito_Habilitadas()
        {
            return periodoService.Listar_Cuenta_Deposito_Habilitadas();
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
                    T_CuotaPagoDesc = x.T_CuotaPagoDesc,
                    N_Anio = x.N_Anio,
                    D_FecIni = x.D_FecIni,
                    D_FecFin = x.D_FecFin
                }).ToList();
            }

            return result;
        }

        public Response Grabar_Periodo(NuevoPeriodoViewModel model)
        {
            var periodo  = new PeriodoEntity()
            {
                I_CuotaPagoID = model.I_CuotaPagoID,
                N_Anio = model.N_Anio,
                D_FecIni = model.D_FecIni,
                D_FecFin = model.D_FecFin
            };

            return periodoService.Grabar_Periodo(periodo);
        }

        public Response Actualizar_Periodo(EdicionPeriodoViewModel model)
        {
            var periodo = new PeriodoEntity()
            {
                I_PeriodoID = model.I_PeriodoID,
                I_CuotaPagoID = model.I_CuotaPagoID,
                N_Anio = model.N_Anio,
                D_FecIni = model.D_FecIni,
                D_FecFin = model.D_FecFin,
                B_Habilitado = model.B_Habilitado
            };

            return periodoService.Grabar_Periodo(periodo);
        }
    }
}