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

        public List<CuotaPago> Listar_Tipo_Periodo_Habilitados()
        {
            return periodoService.Listar_Tipo_Periodo_Habilitados();
        }

        public int Obtener_Prioridad_Tipo_Periodo(int I_TipoPeriodoID)
        {
            return periodoService.Obtener_Prioridad_Tipo_Periodo(I_TipoPeriodoID);
        }

        public List<CuentaDeposito> Listar_Cuenta_Deposito_Habilitadas(int I_TipoPeriodoID)
        {
            return periodoService.Listar_Cuenta_Deposito_Habilitadas(I_TipoPeriodoID);
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
            PeriodoEntity periodo;

            var saveOption = (!model.I_PeriodoID.HasValue) ? SaveOption.Insert : SaveOption.Update;

            periodo  = new PeriodoEntity()
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

            return periodoService.Grabar_Periodo(periodo, saveOption);
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