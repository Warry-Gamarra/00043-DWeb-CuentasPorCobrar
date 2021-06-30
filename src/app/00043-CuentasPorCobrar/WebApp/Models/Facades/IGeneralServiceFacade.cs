using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IGeneralServiceFacade
    {
        IEnumerable<SelectViewModel> Listar_Anios();

        IEnumerable<SelectViewModel> Listar_TipoEstudios();

        IEnumerable<SelectViewModel> Listar_Horas();

        IEnumerable<SelectViewModel> Listar_Minutos();

        IEnumerable<SelectViewModel> Listar_ReportesPregrado();

        IEnumerable<SelectViewModel> Listar_ReportesPosgrado();
    }
}