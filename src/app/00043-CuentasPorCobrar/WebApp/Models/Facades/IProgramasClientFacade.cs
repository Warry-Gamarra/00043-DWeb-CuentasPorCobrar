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
        IEnumerable<SelectViewModel> GetFacultades(TipoEstudio tipoEstudio);

        IEnumerable<SelectViewModel> GetDependencias(TipoEstudio tipoEstudio);

        IEnumerable<SelectViewModel> GetEscuelas(string codFac);

        IEnumerable<SelectViewModel> GetEspecialidades(string codFac);

        IEnumerable<SelectViewModel> GetEspecialidades(string codFac, string codEsc);
    }
}