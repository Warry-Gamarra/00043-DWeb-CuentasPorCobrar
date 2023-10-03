using Domain.Helpers;
using Domain.UnfvRepositorioClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ProgramasClientFacade : IProgramasClientFacade
    {
        IProgramasClient programasClient;

        public ProgramasClientFacade()
        {
            programasClient = new ProgramasClient();
        }

        public IEnumerable<SelectViewModel> GetFacultades(TipoEstudio tipoEstudio, int? dependenciaID)
        {
            IEnumerable<FacultadModel> facultades;
            IEnumerable<EscuelaModel> posgrado;
            IEnumerable<SelectViewModel> result;

            try
            {
                switch (tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        string[] excluidos = { "CA", "CI", "CP", "CV", "EP" };

                        facultades = programasClient.GetFacultades().Where(f => !excluidos.Contains(f.CodFac));

                        if (dependenciaID.HasValue)
                        {
                            facultades = facultades.Where(f => f.DependenciaID.Equals(dependenciaID.Value));
                        }

                        result = facultades.Select(x => new SelectViewModel()
                        {
                            Value = x.CodFac,
                            TextDisplay = x.FacDesc
                        }).OrderBy(f => f.TextDisplay);

                        break;

                    case TipoEstudio.Posgrado:
                        posgrado = programasClient.GetEscuelas("EP");

                        result = posgrado.Select(x => new SelectViewModel()
                        {
                            Value = x.CodEsc,
                            TextDisplay = x.EscDesc
                        }).OrderByDescending(f => f.TextDisplay);

                        break;

                    default:
                        result = new List<SelectViewModel>();

                        break;
                }
            }
            catch (Exception)
            {
                result = new List<SelectViewModel>();
            }
            
            return result;
        }

        public IEnumerable<SelectViewModel> GetDependencias(TipoEstudio tipoEstudio, int? dependenciaID)
        {
            IEnumerable<FacultadModel> facultades;
            IEnumerable<EspecialidadModel> especialidades;
            IEnumerable<SelectViewModel> result;

            try
            {
                switch (tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        string[] excluidos = { "CA", "CI", "CP", "CV", "EP" };

                        facultades = programasClient.GetFacultades().Where(f => !excluidos.Contains(f.CodFac));

                        if (dependenciaID.HasValue)
                        {
                            facultades = facultades.Where(f => f.DependenciaID.Equals(dependenciaID.Value));
                        }

                        result = facultades.Select(x => new SelectViewModel()
                        {
                            Value = x.CodFac,
                            TextDisplay = x.FacDesc
                        }).OrderBy(f => f.TextDisplay);

                        break;

                    case TipoEstudio.Posgrado:
                        facultades = programasClient.GetFacultades().Where(x => x.CodFac == "EP");

                        result = facultades.Select(x => new SelectViewModel()
                        {
                            Value = x.CodFac,
                            TextDisplay = x.FacDesc
                        });

                        break;

                    case TipoEstudio.Segunda_Especialidad:
                        especialidades = programasClient.GetEspecialidades().Where(x => x.N_Grado == "4");

                        result = especialidades
                            .GroupBy(x => new { x.C_CodFac, x.T_FacDesc} )
                            .Select(x => new SelectViewModel() { 
                                Value = x.Key.C_CodFac,
                                TextDisplay = x.Key.T_FacDesc
                            });

                        break;

                    default:
                        result = new List<SelectViewModel>();

                        break;
                }
            }
            catch (Exception)
            {
                result = new List<SelectViewModel>();
            }

            return result;
        }

        public IEnumerable<SelectViewModel> GetEscuelas(string codFac)
        {
            IEnumerable<EscuelaModel> escuelas;
            IEnumerable<SelectViewModel> result;

            try
            {
                escuelas = programasClient.GetEscuelas(codFac);

                result = escuelas.Select(x => new SelectViewModel()
                {
                    Value = x.CodEsc,
                    TextDisplay = x.EscDesc
                }).OrderBy(f => f.TextDisplay);
            }
            catch (Exception)
            {
                result = new List<SelectViewModel>();
            }

            return result;
        }

        public IEnumerable<SelectViewModel> GetEspecialidades(string codFac)
        {
            IEnumerable<EspecialidadModel> especialidades;
            IEnumerable<SelectViewModel> result;

            try
            {
                especialidades = programasClient.GetEspecialidades(codFac);

                result = especialidades.Select(x => new SelectViewModel()
                {
                    Value = x.C_RcCod,
                    TextDisplay = x.T_CarProfDesc
                }).OrderBy(x => x.TextDisplay);
            }
            catch (Exception)
            {
                result = new List<SelectViewModel>();
            }

            return result;
        }

        public IEnumerable<SelectViewModel> GetEspecialidades(string codFac, string codEsc)
        {
            IEnumerable<EspecialidadModel> especialidades;
            IEnumerable<SelectViewModel> result;

            try
            {
                especialidades = programasClient.GetEspecialidades(codFac, codEsc);

                result = especialidades.Select(x => new SelectViewModel()
                {
                    Value = x.C_RcCod,
                    TextDisplay = x.T_CarProfDesc
                }).OrderBy(x => x.TextDisplay);
            }
            catch (Exception)
            {
                result = new List<SelectViewModel>();
            }

            return result;
        }
    }
}