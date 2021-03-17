using Domain.UnfvRepositorioClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.Facades
{
    public interface IAlumnosClientFacade
    {
        IEnumerable<AlumnoModel> GetByDocIdent(string codTipDoc, string numDNI);

        AlumnoModel GetByID(string codRc, string codAlu);

        IEnumerable<EspecialidadAlumnoModel> GetEspecialidadesAlumno(string codAlu);
    }
}