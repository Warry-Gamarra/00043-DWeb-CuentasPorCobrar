using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public interface IAlumnoServiceFacade
    {
        ServiceResponse GrabarAlumno(MantenimientoAlumnoModel alumnoModel, int currentUserID);

        ServiceResponse EditarAlumno(MantenimientoAlumnoModel alumnoModel, int currentUserID);

        IEnumerable<AlumnoModel> GetAll();

        IEnumerable<AlumnoModel> GetByDocIdent(string codTipDoc, string numDNI);

        AlumnoModel GetByID(string codRc, string codAlu);

        IEnumerable<AlumnoModel> GetByCodAlu(string codAlu);
    }
}