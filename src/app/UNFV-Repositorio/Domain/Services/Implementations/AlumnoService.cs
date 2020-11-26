using Data.DTO;
using Data.Repositories;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class AlumnoService : IAlumnoService
    {
        IAlumnoRepository _alumnoRepository;
        IPersonaRepository _personaRepository;

        public AlumnoService(IAlumnoRepository alumnoRepository, IPersonaRepository personaRepository)
        {
            _alumnoRepository = alumnoRepository;
            _personaRepository = personaRepository;
        }

        public ResponseData Create(AlumnoEntity alumnoEntity)
        {
            throw new NotImplementedException();
        }

        public ResponseData Edit(AlumnoEntity alumnoEntity)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<Alumno> GetAll()
        {
            IEnumerable<Alumno> result;

            var alumnos = _alumnoRepository.GetAll();

            if (alumnos == null)
            {
                result = new List<Alumno>();
            }
            else
            {
                result = alumnos.Select(a => new Alumno()
                {

                });
            }

            return result;
        }
    }
}
