using Data.DTO;
using Data.Procedures;
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

        public ServiceResponse Create(AlumnoEntity alumnoEntity)
        {
            ResponseData responseData;
            USP_I_GrabarPersona paramGrabarPersona;
            USP_I_GrabarAlumno paramGrabarAlumno;

            try
            {
                var personas = _personaRepository.GetByDocIdent(alumnoEntity.C_CodTipDoc, alumnoEntity.C_NumDNI);

                if (personas.Count() > 1)
                {
                    throw new Exception("Existen más de una persona con el mismo Número de Documento de Identidad.");
                }

                var alumnos = _alumnoRepository.GetByID(alumnoEntity.C_RcCod, alumnoEntity.C_CodAlu);

                if (alumnos != null)
                {
                    throw new Exception("El Código de Alumno se repite  en el sistema.");
                }

                paramGrabarPersona = Mapper.AlumnoEntity_To_USP_I_GrabarPersona(alumnoEntity);

                paramGrabarAlumno = Mapper.AlumnoEntity_To_USP_I_GrabarAlumno(alumnoEntity);

                if (personas.Count() == 1)
                {
                    paramGrabarAlumno.I_PersonaID = personas.First().I_PersonaID;
                }
                
                responseData = _alumnoRepository.Create(paramGrabarPersona, paramGrabarAlumno);
            }
            catch (Exception ex)
            {
                responseData = new ResponseData()
                {
                    Value = false,
                    Message = ex.Message
                };
            }
            
            return new ServiceResponse(responseData);
        }

        public ServiceResponse Edit(AlumnoEntity alumnoEntity)
        {
            ResponseData responseData;

            try
            {
                var persona = _personaRepository.GetByID(alumnoEntity.I_PersonaID);

                if (persona == null)
                {
                    throw new Exception("La persona no existe en el sistema.");
                }

                var personas = _personaRepository.GetByDocIdent(alumnoEntity.C_CodTipDoc, alumnoEntity.C_NumDNI).Where(p => !p.I_PersonaID.Equals(alumnoEntity.I_PersonaID));

                if (personas.Count() > 0)
                {
                    throw new Exception("El Número de Documento de Identidad se repite en el sistema.");
                }

                var alumno = _alumnoRepository.GetByID(alumnoEntity.C_RcCod, alumnoEntity.C_CodAlu);

                if (alumno == null)
                {
                    throw new Exception("El alumno no existe en el sistema.");
                }

                var paramActualizarPersona = Mapper.AlumnoEntity_To_USP_U_ActualizarPersona(alumnoEntity);

                var paramActualizarAlumno = Mapper.AlumnoEntity_To_USP_U_ActualizarAlumno(alumnoEntity);

                responseData = _alumnoRepository.Edit(paramActualizarPersona, paramActualizarAlumno);
            }
            catch (Exception ex)
            {
                responseData = new ResponseData()
                {
                    Value = false,
                    Message = ex.Message
                };
            }

            return new ServiceResponse(responseData);
        }

        public IEnumerable<AlumnoDTO> GetAll()
        {
            IEnumerable<AlumnoDTO> result;

            var alumnos = _alumnoRepository.GetAll();

            if (alumnos == null)
                result = new List<AlumnoDTO>();
            else
            {
                result = alumnos.Select(a => Mapper.VW_Alumnos_To_AlumnoDTO(a));
            }

            return result;
        }

        public IEnumerable<AlumnoDTO> GetByDocIdent(string codTipDoc, string numDNI)
        {
            IEnumerable<AlumnoDTO> result;

            var alumnos = _alumnoRepository.GetByDocIdent(codTipDoc, numDNI);

            if (alumnos == null)
                result = new List<AlumnoDTO>();
            else
            {
                result = alumnos.Select(a => Mapper.VW_Alumnos_To_AlumnoDTO(a));
            }

            return result;
        }

        public AlumnoDTO GetByID(string codRc, string codAlu)
        {
            var alumno = _alumnoRepository.GetByID(codRc, codAlu);

            var result = (alumno == null) ? null : Mapper.VW_Alumnos_To_AlumnoDTO(alumno);

            return result;
        }

        public IEnumerable<AlumnoDTO> GetByCodAlu(string codAlu)
        {
            IEnumerable<AlumnoDTO> result;

            var alumnos = _alumnoRepository.GetByCodAlu(codAlu);

            if (alumnos == null)
                result = new List<AlumnoDTO>();
            else
            {
                result = alumnos.Select(a => Mapper.VW_Alumnos_To_AlumnoDTO(a));
            }

            return result;
        }
    }
}
