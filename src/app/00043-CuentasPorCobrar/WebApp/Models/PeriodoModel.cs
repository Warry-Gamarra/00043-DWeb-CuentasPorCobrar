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

        public Response GrabarPeriodo(NuevoPeriodoViewModel model)
        {
            var periodo  = new Periodo()
            {
                Cuota_Pago_ID = model.Cuota_Pago_ID,
                N_Anio = model.Anio,
                D_FecIni = model.Fecha_Inicio,
                D_FecFin = model.Fecha_Vencimiento
            };

            return periodoService.GrabarPeriodo(periodo);
        }
    }
}