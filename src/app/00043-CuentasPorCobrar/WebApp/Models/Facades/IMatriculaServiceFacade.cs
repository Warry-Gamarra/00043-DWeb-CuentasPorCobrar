using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IMatriculaServiceFacade
    {
        MatriculaModel GetMatricula(int anio, int periodo, string codAlu, string codRc);

        IEnumerable<MatriculaModel> GetMatriculas(int anio, int periodo, TipoEstudio tipoEstudio);
    }
}