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

        private readonly string PREGRADO = "1";
        private readonly string SEGUNDA_ESPECIALIDAD = "4";
        private readonly string RESIDENTADO = "5";

        public ProgramasClientFacade()
        {
            programasClient = new ProgramasClient();
        }

        public IEnumerable<SelectViewModel> GetFacultades(TipoEstudio tipoEstudio, int? dependenciaID)
        {
            IEnumerable<EspecialidadModel> especialidades;
            IEnumerable<EscuelaModel> posgrado;
            IEnumerable<SelectViewModel> result;

            try
            {
                switch (tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        string[] excluidos = { "CA", "CI", "CP", "CV", "EP" };

                        especialidades = programasClient.GetEspecialidades().Where(x => x.N_Grado == PREGRADO && !excluidos.Contains(x.C_CodFac));

                        if (dependenciaID.HasValue)
                        {
                            especialidades = especialidades.Where(f => f.I_DependenciaID.HasValue && f.I_DependenciaID.Value.Equals(dependenciaID.Value));
                        }

                        result = especialidades
                           .GroupBy(x => new { x.C_CodFac, x.T_FacDesc })
                           .Select(x => new SelectViewModel()
                           {
                               Value = x.Key.C_CodFac,
                               TextDisplay = x.Key.T_FacDesc
                           })
                           .OrderBy(x => x.TextDisplay);

                        break;

                    case TipoEstudio.Posgrado:
                        posgrado = programasClient.GetEscuelas("EP");

                        result = posgrado.Select(x => new SelectViewModel()
                        {
                            Value = x.CodEsc,
                            TextDisplay = x.EscDesc
                        }).OrderByDescending(f => f.TextDisplay);

                        break;

                    case TipoEstudio.Segunda_Especialidad:
                        especialidades = programasClient.GetEspecialidades().Where(x => x.N_Grado == SEGUNDA_ESPECIALIDAD);

                        if (dependenciaID.HasValue)
                        {
                            especialidades = especialidades.Where(f => f.I_DependenciaID.HasValue && f.I_DependenciaID.Value.Equals(dependenciaID.Value));
                        }

                        result = especialidades
                            .GroupBy(x => new { x.C_CodFac, x.T_FacDesc })
                            .Select(x => new SelectViewModel()
                            {
                                Value = x.Key.C_CodFac,
                                TextDisplay = x.Key.T_FacDesc
                            });

                        break;

                    case TipoEstudio.Residentado:
                        especialidades = programasClient.GetEspecialidades().Where(x => x.N_Grado == RESIDENTADO);

                        if (dependenciaID.HasValue)
                        {
                            especialidades = especialidades.Where(f => f.I_DependenciaID.HasValue && f.I_DependenciaID.Value.Equals(dependenciaID.Value));
                        }

                        result = especialidades
                            .GroupBy(x => new { x.C_CodFac, x.T_FacDesc })
                            .Select(x => new SelectViewModel()
                            {
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

                        especialidades = programasClient.GetEspecialidades().Where(x => x.N_Grado == PREGRADO && !excluidos.Contains(x.C_CodFac));

                        if (dependenciaID.HasValue)
                        {
                            especialidades = especialidades.Where(f => f.I_DependenciaID.HasValue && f.I_DependenciaID.Value.Equals(dependenciaID.Value));
                        }

                        result = especialidades
                           .GroupBy(x => new { x.C_CodFac, x.T_FacDesc })
                           .Select(x => new SelectViewModel() {
                               Value = x.Key.C_CodFac,
                               TextDisplay = x.Key.T_FacDesc
                           })
                           .OrderBy(x => x.TextDisplay);

                        break;

                    case TipoEstudio.Posgrado:
                        facultades = programasClient.GetFacultades().Where(x => x.CodFac == "EP");

                        result = facultades.Select(x => new SelectViewModel() {
                            Value = x.CodFac,
                            TextDisplay = x.FacDesc
                        });

                        break;

                    case TipoEstudio.Segunda_Especialidad:
                        especialidades = programasClient.GetEspecialidades().Where(x => x.N_Grado == SEGUNDA_ESPECIALIDAD);

                        if (dependenciaID.HasValue)
                        {
                            especialidades = especialidades.Where(f => f.I_DependenciaID.HasValue && f.I_DependenciaID.Value.Equals(dependenciaID.Value));
                        }

                        result = especialidades
                            .GroupBy(x => new { x.C_CodFac, x.T_FacDesc} )
                            .Select(x => new SelectViewModel() { 
                                Value = x.Key.C_CodFac,
                                TextDisplay = x.Key.T_FacDesc
                            });

                        break;

                    case TipoEstudio.Residentado:
                        especialidades = programasClient.GetEspecialidades().Where(x => x.N_Grado == RESIDENTADO);

                        if (dependenciaID.HasValue)
                        {
                            especialidades = especialidades.Where(f => f.I_DependenciaID.HasValue && f.I_DependenciaID.Value.Equals(dependenciaID.Value));
                        }

                        result = especialidades
                            .GroupBy(x => new { x.C_CodFac, x.T_FacDesc })
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

        public IEnumerable<SelectViewModel> GetEscuelas(TipoEstudio tipoEstudio, string codFac)
        {
            IEnumerable<EscuelaModel> escuelas;
            IEnumerable<EspecialidadModel> especialidades;
            IEnumerable<SelectViewModel> result;

            try
            {
                switch (tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        especialidades = programasClient.GetEspecialidades()
                            .Where(x => x.N_Grado == PREGRADO && x.C_CodFac == codFac);

                        result = especialidades
                            .GroupBy(x => new { x.C_CodEsc, x.T_EscDesc })
                            .Select(x => new SelectViewModel()
                            {
                                Value = x.Key.C_CodEsc,
                                TextDisplay = x.Key.T_EscDesc
                            });

                        break;

                    case TipoEstudio.Posgrado:
                        escuelas = programasClient.GetEscuelas(codFac);

                        result = escuelas.Select(x => new SelectViewModel()
                        {
                            Value = x.CodEsc,
                            TextDisplay = x.EscDesc
                        }).OrderBy(f => f.TextDisplay);

                        break;

                    case TipoEstudio.Segunda_Especialidad:
                        especialidades = programasClient.GetEspecialidades()
                            .Where(x => x.N_Grado == SEGUNDA_ESPECIALIDAD && x.C_CodFac == codFac);

                        result = especialidades
                            .GroupBy(x => new { x.C_CodEsc, x.T_EscDesc })
                            .Select(x => new SelectViewModel()
                            {
                                Value = x.Key.C_CodEsc,
                                TextDisplay = x.Key.T_EscDesc
                            });

                        break;

                    case TipoEstudio.Residentado:
                        especialidades = programasClient.GetEspecialidades()
                            .Where(x => x.N_Grado == RESIDENTADO && x.C_CodFac == codFac);

                        result = especialidades
                            .GroupBy(x => new { x.C_CodEsc, x.T_EscDesc })
                            .Select(x => new SelectViewModel()
                            {
                                Value = x.Key.C_CodEsc,
                                TextDisplay = x.Key.T_EscDesc
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

        public IEnumerable<SelectViewModel> GetEspecialidades(TipoEstudio tipoEstudio, string codFac, string codEsc)
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