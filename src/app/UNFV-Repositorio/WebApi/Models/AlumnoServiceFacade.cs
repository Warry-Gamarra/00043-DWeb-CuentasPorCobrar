using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public class AlumnoServiceFacade : IAlumnoServiceFacade
    {
        IAlumnoService _alumnoService;

        public AlumnoServiceFacade(IAlumnoService alumnoService)
        {
            _alumnoService = alumnoService;
        }
        public ServiceResponse GrabarAlumno(MantenimientoAlumnoModel alumnoModel, int currentUserID)
        {
            var alumnoEntity = Mapper.MantenimientoAlumnoModel_To_AlumnoEntity(alumnoModel, currentUserID);

            return _alumnoService.Create(alumnoEntity);
        }

        public ServiceResponse EditarAlumno(MantenimientoAlumnoModel alumnoModel, int currentUserID)
        {
            var alumnoEntity = Mapper.MantenimientoAlumnoModel_To_AlumnoEntity(alumnoModel, currentUserID);

            return _alumnoService.Edit(alumnoEntity);
        }

        public IEnumerable<AlumnoModel> GetAll()
        {
            return _alumnoService.GetAll().Select(a => Mapper.AlumnoDTO_To_AlumnoModel(a));
        }

        public IEnumerable<AlumnoModel> GetByDocIdent(string codTipDoc, string numDNI)
        {
            return _alumnoService.GetByDocIdent(codTipDoc, numDNI).Select(a => Mapper.AlumnoDTO_To_AlumnoModel(a));
        }

        public AlumnoModel GetByID(string codRc, string codAlu)
        {
            var alumnoDTO = _alumnoService.GetByID(codRc, codAlu);

            return Mapper.AlumnoDTO_To_AlumnoModel(alumnoDTO);
        }

        public IEnumerable<AlumnoModel> GetByCodAlu(string codAlu)
        {
            return _alumnoService.GetByCodAlu(codAlu).Select(a => Mapper.AlumnoDTO_To_AlumnoModel(a));
        }
    }
}