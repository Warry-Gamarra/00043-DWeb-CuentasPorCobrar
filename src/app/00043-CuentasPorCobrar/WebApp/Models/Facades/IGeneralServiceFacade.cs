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

        IEnumerable<SelectViewModel> Listar_TipoEstudios(int? DependenciaID);

        IEnumerable<SelectViewModel> Listar_Horas();

        IEnumerable<SelectViewModel> Listar_Minutos();

        IEnumerable<SelectViewModel> Listar_TipoReporteObligaciones(int? DependenciaID);

        IEnumerable<SelectViewModel> Listar_TipoAlumno();

        IEnumerable<SelectViewModel> Listar_CondicionExistenciaObligaciones();

        IEnumerable<SelectViewModel> Listar_CondicionPagoObligacion();
        IEnumerable<SelectViewModel> Listar_TiposPago();
    }
}