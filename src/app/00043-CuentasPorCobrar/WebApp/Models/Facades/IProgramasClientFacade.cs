using Domain.Helpers;
using Domain.UnfvRepositorioClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IProgramasClientFacade
    {
        IEnumerable<SelectViewModel> GetFacultades(TipoEstudio tipoEstudio, int? dependenciaID);

        IEnumerable<SelectViewModel> GetDependencias(TipoEstudio tipoEstudio, int? dependenciaID);

        IEnumerable<SelectViewModel> GetEscuelas(TipoEstudio tipoEstudio, string codFac);

        IEnumerable<SelectViewModel> GetEspecialidades(string codFac);

        IEnumerable<SelectViewModel> GetEspecialidades(TipoEstudio tipoEstudio, string codFac, string codEsc);
    }
}